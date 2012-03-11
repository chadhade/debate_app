module DebatersHelper
  
  def gravatar_for(debater, options = { :size => 50})
    gravatar_image_tag(debater.email.downcase, :alt => debater.name, :class => 'gravatar', :gravatar => options)
  end
  
end
