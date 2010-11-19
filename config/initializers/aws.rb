AWS::S3::Base.establish_connection!(
  :access_key_id     => OPTIONS[:s3_key],
  :secret_access_key => OPTIONS[:s3_secret]
)