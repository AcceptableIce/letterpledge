class User < ApplicationRecord
	validates :email_address, uniqueness: true, length: { minimum: 5 }
end
