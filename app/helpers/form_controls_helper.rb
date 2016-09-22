# Helper methods pertaining to form controls and collections of form controls.
module FormControlsHelper
  def yes_no_question(f, field, label, params = {})
    params.reverse_merge!(
      f: f,
      field: field,
      label: label,
      label_class: params[:class] || '',
      yes_label: 'Yes',
      no_label: 'No',
      check_yes: nil,
      check_no: nil,
      help_title: nil,
      help_content: nil
    ).except!(:class)  # Remove 'class' param to avoid issues because it's a keyword.

    render partial: "yes_no_question", locals: params
  end

  def checkbox_grid(f, method, collection, width)
    content_tag :div, class: 'checkbox-grid' do
      f.collection_check_boxes method, collection, :to_s, :to_s, include_hidden: false do |b|
        content_tag :div, b.check_box + b.label, class: 'item', style: "width: #{width}px;"
      end
    end
  end

  def radio_button_grid(f, method, collection, width, popovers = {})
    content_tag :div, class: 'checkbox-grid' do
      collection.map do |item|
        content_tag :div, class: 'item', style: "width: #{width}px;" do
          content_tag(:label, f.radio_button(method, item) + content_tag(:span, item)) + popover(item, popovers[item])
        end
      end.reduce(&:+)
    end
  end

  def popover(title, content)
    if content
      content_tag :div, '', class: 'help-tip', title: title,
                            data: { toggle: 'popover', trigger: 'hover', content: content }
    end
  end
end
