module ApplicationHelper
  
  def current_or_guest_debater
    if current_debater
      if session[:guest_debater_id]
        logging_in
        session[:guest_debater_id] = nil
      end
      current_debater
    else
      guest_debater
    end
  end

  def guest_debater
    Debater.find(session[:guest_debater_id].nil? ? session[:guest_debater_id] = create_guest_debater.id : session[:guest_debater_id])
  end

  # called (once) when the user logs in, insert any code your application needs
  # to hand off from guest_user to current_user.
  def logging_in
  end

  private

  def create_guest_debater
    u = Debater.create(:name => "guest#{(Time.now - 15380.days).to_i.to_s.reverse}#{rand(9)}", :email => "guest_#{Time.now.to_i}#{rand(99)}@debunky.com", :password => generated_password(8))
    u.save!
    u
  end
 
  def generated_password(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    return Array.new(len){||chars[rand(chars.size)]}.join
  end
end
