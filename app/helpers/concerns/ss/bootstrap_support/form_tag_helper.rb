module SS::BootstrapSupport::FormTagHelper
  extend ActiveSupport::Concern
  include SS::BootstrapSupport::Common

  # see: actionview-4.2.9/lib/action_view/helpers/form_tag_helper.rb

  # def form_tag(url_for_options = {}, options = {}, &block)
  #   super
  # end

  def select_tag(name, option_tags = nil, options = {})
    options = options.with_indifferent_access
    css_class = bt_sup_normalize_css_class(options[:class])
    css_class = bt_sup_merge_css_class(css_class, %w(form-control))

    options[:class] = css_class
    super(name, option_tags, options)
  end

  def text_field_tag(name, value = nil, options = {})
    options = options.with_indifferent_access
    css_class = bt_sup_normalize_css_class(options[:class])
    css_class = bt_sup_merge_css_class(css_class, %w(form-control))

    options[:class] = css_class
    super(name, value, options)
  end

  # def label_tag(name = nil, content_or_options = nil, options = nil, &block)
  #   super
  # end

  # def hidden_field_tag(name, value = nil, options = {})
  #   super
  # end

  def file_field_tag(name, options = {})
    options = options.with_indifferent_access
    options[:class] = bt_sup_merge_css_class(options[:class], %w(form-control-file))
    super(name, value, options)
  end

  # def password_field_tag(name = "password", value = nil, options = {})
  #   super
  # end

  # def text_area_tag(name, content = nil, options = {})
  #   super
  # end

  # def check_box_tag(name, value = "1", checked = false, options = {})
  #   super
  # end

  # def radio_button_tag(name, value, checked = false, options = {})
  #   super
  # end

  def submit_tag(value = "Save changes", options = {})
    options = options.with_indifferent_access
    css_class = bt_sup_normalize_css_class(options[:class])

    additions = []
    if (css_class & %w(save btn-primary btn-default btn-danger)).present?
      additions += %w(btn btn-raised btn-lg)
    end
    if css_class.include?('save')
      additions << 'btn-primary'
    end
    if additions.blank? && bt_sup_include_btn_only?(css_class)
      additions << 'btn-outline'
    end

    if additions.present?
      options[:class] = bt_sup_merge_css_class(css_class, additions)
    end

    super(value, options)
  end

  def button_tag(content_or_options = nil, options = nil, &block)
    if content_or_options.is_a? Hash
      options = content_or_options
    else
      options ||= {}
    end
    options = options.with_indifferent_access

    css_class = bt_sup_normalize_css_class(options[:class])
    if (css_class & %w(btn-primary btn-default btn-danger')).present?
      css_class = bt_sup_merge_css_class(css_class, %w(btn btn-raised btn-lg))
    end
    if bt_sup_include_btn_only?(css_class)
      css_class = bt_sup_merge_css_class(css_class, %w(btn-outline))
    end

    options[:class] = css_class
    super(content_or_options, options, &block)
  end

  # def image_submit_tag(source, options = {})
  #   super
  # end

  # def field_set_tag(legend = nil, options = nil, &block)
  #   super
  # end

  # def color_field_tag(name, value = nil, options = {})
  #   super
  # end

  # def search_field_tag(name, value = nil, options = {})
  #   super
  # end

  # def telephone_field_tag(name, value = nil, options = {})
  #   super
  # end

  # def date_field_tag(name, value = nil, options = {})
  #   super
  # end

  # def time_field_tag(name, value = nil, options = {})
  #   super
  # end

  # def datetime_field_tag(name, value = nil, options = {})
  #   super
  # end

  # def datetime_local_field_tag(name, value = nil, options = {})
  #   super
  # end

  # def month_field_tag(name, value = nil, options = {})
  #   super
  # end

  # def week_field_tag(name, value = nil, options = {})
  #   super
  # end

  # def url_field_tag(name, value = nil, options = {})
  #   super
  # end

  # def email_field_tag(name, value = nil, options = {})
  #   super
  # end

  # def number_field_tag(name, value = nil, options = {})
  #   super
  # end

  # def range_field_tag(name, value = nil, options = {})
  #   super
  # end

  # def utf8_enforcer_tag
  #   super
  # end

  def ss_field_tag_set(name, value = nil, options = {})
    tt = options.delete(:tt)
    content_tag(:div, class: "col12 mb-3") do
      output_buffer << label_tag(name) do
        output_buffer << options.delete(:label)
        if tt
          output_buffer << tt
        end
      end

      if block_given?
        output_buffer << capture { yield }
      else
        case guess_type(options.delete(:type), value)
        when :text
          output_buffer << text_field_tag(name, value, options)
        when :password
          output_buffer << password_field_tag(name, value, options)
        when :email
          output_buffer << email_field_tag(name, value, options)
        when :url
          output_buffer << url_field(name, value, options)
        when :tel
          output_buffer << telephone_field_tag(name, value, options)
        when :hidden
          output_buffer << hidden_field_tag(name, value, options)
        when :number
          output_buffer << number_field_tag(name, value, options)
        when :file
          output_buffer << file_field_tag(name, options)
        when :text_area
          output_buffer << text_area_tag(name, value, options)
        when :date
          options[:class] = %w(date js-date)
          value = value ? I18n.l(value.to_date, format: :picker) : nil
          output_buffer << text_field_tag(name, value, options)
        when :datetime
          options[:class] = %w(datetime js-datetime)
          value = value ? I18n.l(value, format: :picker) : nil
          output_buffer << text_field_tag(name, value, options)
        else
          raise "unknown type: #{type}"
        end
      end
    end
  end

  private

  def guess_type(type, value)
    return type if type.present? && type != :auto

    case value
    when Integer
      :number
    when DateTime
      :datetime
    else
      :text
    end
  end
end
