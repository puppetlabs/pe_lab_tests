# pe_lab_tests

This project contains acceptance tests for servers in TechEd PE Labs.

## Requirements

This project requires Puppet Bolt in order to run, and PDK for development.

Execution requires a Ruby installation, which the bolt plan `pe_lab_tests::run_server_spec` will create for you on the target node.

SSH access to servers is required to be configured beforehand, including SSH keys.

## Usage

### Running Server Specs with Bolt

This project includes a Bolt plan that automates the setup and execution of server specs on remote targets.

#### Basic Usage

Run a server spec on target servers:

```bash
# Run a specific spec file on all targets in your inventory
bolt plan run pe_lab_tests::run_server_spec spec_file=puppet_server_spec.rb --targets linux_servers

# Run with a specific Ruby version
bolt plan run pe_lab_tests::run_server_spec \
  spec_file=puppet_server_spec.rb \
  ruby_version=3.1.4 \
  --targets rocky8-server

# Run as a specific user
bolt plan run pe_lab_tests::run_server_spec \
  spec_file=puppet_server_spec.rb \
  user=puppet \
  --targets production_servers
```

#### Plan Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `spec_file` | String | *required* | Name of the spec file to run (e.g., 'puppet_server_spec.rb') |
| `ruby_version` | String | `3.2.5` | Ruby version to install using rbenv |
| `user` | String | `sysadmin` | User account to own the project files |

#### What the Plan Does

1. **Installs Ruby** - Uses rbenv to install the specified Ruby version
2. **Copies Project** - Uploads the entire project to the target server
3. **Installs Dependencies** - Runs `bundle install` to install required gems
4. **Runs Specs** - Executes the specified spec file using RSpec
5. **Reports Results** - Shows test output and exit status

#### Spec Files

All specs run by this project are in [`spec/localhost`](spec/localhost). This is to separate serverspec tests from unit tests run with `pdk test unit`.
