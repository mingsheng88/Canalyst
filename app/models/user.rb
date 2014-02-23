class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:facebook, :twitter, :google, :linkedin]

  has_many :authentications, dependent: :delete_all

  def self.find_for_facebook_oauth(auth)
    existing_user = find_by_email(auth.info.email) 
    if existing_user
      if !existing_user.authentications.exists?(uid: auth.uid, provider: auth.provider)
        existing_user.authentications.build(uid: auth.uid, provider: auth.provider, token: auth.credentials.token)
        existing_user.save
      end
      existing_user
    else
      includes(:authentications)
      .where('authentications.provider = ? and authentications.uid = ?', 
        auth.provider, 
        auth.uid)
      .references(:authentications)
      .first_or_create do |user|
        user.email = auth.info.email
        user.password = Devise.friendly_token[0,20]
        user.authentications.build(uid: auth.uid, provider: auth.provider, token: auth.credentials.token)
      end
    end
  end
end
