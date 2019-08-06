module MailHelper
    def self.confirme_mail(mail, token)
        Pony.mail(
            :to => mail, 
            :from => 'noreply@matcha.fr', 
            :subject => '=?UTF-8?B?Q29uZmlybSB5b3VyIG1hdGNoYSBhY2NvdW50IOKdpO+4jw==?=', 
            :body => "Hello there , click on the link to confirme your account and start finding love  http://matcha/?token=#{token}")
    end
    def self.reset_mail(mail, token)
        Pony.mail(
            :to => mail, 
            :from => 'noreply@matcha.fr', 
            :subject => 'Did you forgot your Matcha password ?', 
            :body => "Hello there , click on the link to reset your password account and start finding love again  http://matcha/?token=#{token}")
        end
end
