ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  "<span class='error_field'>#{html_tag}</span>".html_safe
end

