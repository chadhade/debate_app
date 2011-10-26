module SessionsHelper

  def sign_in(debater)
    cookies.permanent.signed[:remember_token] = [debater.id]
	self.current_debater = debater
  end
  
  def current_debater=(debater)
	@current_debater = debater
  end
  
  def current_debater
	@current_debater ||= debater_from_remember_token
  end
  
  def signed_in?
    !current_debater.nil?
  end
  
  def sign_out
	cookies.delete(:remember_token)
	self.current_debater = nil
  end
  
  private
  
    def debater_from_remember_token
	  debater = Debater.find_by_id(cookies.signed[:remember_token])
	  return nil if debater.nil?
	  return debater
	end

end
