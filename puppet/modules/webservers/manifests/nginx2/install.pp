class webservers::nginx::install {
  include webservers::nginx::repo
  include webservers::nginx::package
  include webservers::nginx::config
  include webservers::nginx::service
}
