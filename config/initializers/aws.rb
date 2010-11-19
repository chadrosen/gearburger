if Rails.env.to_s == "production" || Rails.env.to_s == "staging"
  AWS::S3::Base.establish_connection!(
    :access_key_id     => OPTIONS[:s3_key],
    :secret_access_key => OPTIONS[:s3_secret]
  )
end