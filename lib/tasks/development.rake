namespace :development do

  desc 'Remove personal data'
  task remove_personal_data: :environment do
    clear_password = 'warecorp'
    salt = User.generate_salt
    hashed_password = User.hash_password("#{salt}#{User.hash_password clear_password}")
    users_sql = %{
      UPDATE users SET
        mail = CONCAT(mail, '.blocked'),
        salt = '#{salt}',
        hashed_password = '#{hashed_password}'
    }

    ActiveRecord::Base.connection.execute(users_sql)
  end

end
