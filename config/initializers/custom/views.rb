# ActionView override configuration goes here.

# Override ActionView's field_error_proc to wrap form fields with errors
# in a .has-errors div (this is a boostrap class to highlight fields with errors).

ActionView::Base.field_error_proc = proc do |html_tag, instance|
  # We need to use .html_safe at the end due to field_error_proc handling,
  # and it's not a big deal anyway because there's no user content to worry about.
  # rubocop:disable Rails/OutputSafety
  if html_tag =~ /^<label/
    doc = Nokogiri::HTML::DocumentFragment.parse(html_tag)
    text_span = doc.children[0]
    text_span.inner_html = "<span class='has-error'><span class='control-label'>#{text_span.text} " \
                           "(#{instance.error_message.first})</span></span>"
    doc.to_html
  elsif html_tag !~ /type="radio/
    "<div class=\"control-group has-error\">#{html_tag}</div>"
  else
    html_tag
  end.html_safe
  # rubocop:enable Rails/OutputSafety
end
