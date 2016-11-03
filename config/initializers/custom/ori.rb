# App should fail to start if ORI data isn't loaded.

unless Rails.env.test?
  if !defined?(Constants::CONTRACTING_ORIS)
    raise "Constants::CONTRACTING_ORIS not specified! Have you run `docker-compose run data`?"
  elsif !defined?(Constants::DEPARTMENT_BY_ORI)
    raise "Constants::DEPARTMENT_BY_ORI not specified! Have you run `docker-compose run data`?"
  end
end
