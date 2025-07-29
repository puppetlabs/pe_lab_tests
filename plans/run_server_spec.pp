# @summary Run a specific server spec on target servers
#
# This plan installs Ruby using rbenv, copies the entire project
# to the target server, and runs a specified spec file.
#
# @param targets
#   The targets to run the plan on
# @param spec_file
#   The name of the spec file to run (e.g., 'puppet_server_spec.rb')
# @param ruby_version
#   The Ruby version to install (default: 3.2.5)
# @param project_dest
#   Destination directory on target server (default: /opt/pe_lab_tests)
# @param user
#   User to own the project files (default: current user)
#
plan pe_lab_tests::run_server_spec (
  TargetSpec $targets,
  String $spec_file,
  String $ruby_version = '3.2.5',
  String $project_dest = '/opt/pe_lab_tests',
  Optional[String] $user = undef
) {
  # Get the current project directory
  $project_source = system::env('PWD')

  out::message("Running server spec: ${spec_file}")
  out::message("Ruby version: ${ruby_version}")
  out::message("Project destination: ${project_dest}")

  # Step 1: Install Ruby using our custom task
  out::message("Step 1: Installing Ruby ${ruby_version}...")
  run_task('pe_lab_tests::install_ruby', $targets, {
    'ruby_version' => $ruby_version
  })

  # Step 2: Create destination directory
  out::message('Step 2: Creating project directory...')
  run_command("sudo mkdir -p ${project_dest}", $targets)

  # Step 3: Set ownership if user specified
  if $user {
    run_command("sudo chown -R ${user}:${user} ${project_dest}", $targets)
  }

  # Step 4: Copy the entire project to target servers
  out::message('Step 3: Copying project files...')
  upload_file($project_source, $project_dest, $targets, {
    '_run_as' => $user
  })

  # Step 5: Install project dependencies
  out::message('Step 4: Installing project dependencies...')
  run_command("cd ${project_dest} && ~/.rbenv/shims/bundle install", $targets, {
    '_run_as' => $user
  })

  # Step 6: Verify the spec file exists
  out::message('Step 5: Verifying spec file exists...')
  $spec_path = "${project_dest}/spec/localhost/${spec_file}"
  $file_check = run_command("test -f ${spec_path} && echo 'exists' || echo 'not found'", $targets)

  $file_check.each |$result| {
    if $result.value['stdout'].strip == 'not found' {
      fail_plan("Spec file ${spec_file} not found at ${spec_path} on target ${result.target}")
    }
  }

  # Step 7: Run the specified spec file
  out::message("Step 6: Running spec file: ${spec_file}...")
  $spec_results = run_command("cd ${project_dest} && ~/.rbenv/shims/bundle exec rspec spec/localhost/${spec_file} --format documentation", $targets, {
    '_run_as' => $user
  })

  # Step 8: Display results
  out::message('Spec Results:')
  $spec_results.each |$result| {
    out::message("Target: ${result.target}")
    out::message("Exit Code: ${result.value['exit_code']}")
    out::message('Output:')
    out::message($result.value['stdout'])

    if $result.value['stderr'] != '' {
      out::message('Errors:')
      out::message($result.value['stderr'])
    }
  }

  # Determine overall success
  $failed_targets = $spec_results.filter |$result| { $result.value['exit_code'] != 0 }
  $success = $failed_targets.length == 0

  if $success {
    out::message('✅ All specs passed successfully!')
    $status = 'success'
  } else {
    out::message("❌ Some specs failed on targets: ${failed_targets.map |$r| { $r.target }}")
    $status = 'failed'
  }

  return {
    status              => $status,
    spec_file           => $spec_file,
    ruby_version        => $ruby_version,
    project_destination => $project_dest,
    targets_tested      => $targets,
    results             => $spec_results.map |$result| {
      {
        target    => $result.target,
        exit_code => $result.value['exit_code'],
        passed    => $result.value['exit_code'] == 0
      }
    }
  }
}
