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
# @param user
#   User to own the project files (default: current user)
#
plan pe_lab_tests::run_server_spec (
  TargetSpec $targets,
  String $spec_file,
  String $ruby_version = '3.2.5',
  Optional[String] $user = undef
) {
  # Determine effective user
  $effective_user = $user ? {
    undef   => system::env('USER'),
    default => $user
  }

  # Get the current project directory
  $project_source = system::env('PWD')

  # Set the project destination directory
  $project_dest = "/home/${effective_user}/pe_lab_tests"

  out::message("Running server spec: ${spec_file}")
  out::message("Ruby version: ${ruby_version}")
  out::message("Project destination: ${project_dest}")

  # Install Ruby using our custom task
  out::message("Step 1: Installing Ruby ${ruby_version}...")
  run_task('pe_lab_tests::install_ruby', $targets, {
      'ruby_version' => $ruby_version
  })

  # Create destination directory  
  out::message('Step 2: Creating project directory...')
  run_command("rm -rf ${project_dest}/*", $targets, {
      '_run_as' => 'root'
  })
  run_command("mkdir -p ${project_dest}", $targets, {
      '_run_as' => 'root'
  })

  # Set ownership of target directory
  out::message('Step 3: Setting ownership of project directory...')
  run_command("chown -R ${effective_user}:${effective_user} ${project_dest}", $targets, {
    '_run_as' => 'root'
  })

  # Copy the entire project to target servers
  out::message('Step 4: Copying project files...')
  upload_file("${project_source}/*", $project_dest, $targets)

  # Install project dependencies
  out::message('Step 5: Installing project dependencies...')
  run_command("cd ${project_dest} && ~/.rbenv/shims/bundle install", $targets, {
      '_run_as' => $user
  })

  # Verify the spec file exists
  out::message('Step 6: Verifying spec file exists...')
  $spec_path = "${project_dest}/spec/localhost/${spec_file}"
  $file_check = run_command("test -f ${spec_path} && echo 'exists' || echo 'not found'", $targets)

  $file_check.each |$result| {
    if $result.value['stdout'].strip == 'not found' {
      fail_plan("Spec file ${spec_file} not found at ${spec_path} on target ${result.target}")
    }
  }

  # Run the specified spec file
  out::message("Step 7: Running spec file: ${spec_file}...")
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
