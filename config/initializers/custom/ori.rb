# App should fail to start if ORI data isn't loaded.

Rails.configuration.after_initialize do
  begin
    Constants::CONTRACTING_ORIS
  rescue LoadError
    raise "Constants::CONTRACTING_ORIS not specified! Have you run `docker-compose run data`?"
  end

  begin
    Constants::DEPARTMENT_BY_ORI
  rescue LoadError
    raise "Constants::DEPARTMENT_BY_ORI not specified! Have you run `docker-compose run data`?"
  end
end
