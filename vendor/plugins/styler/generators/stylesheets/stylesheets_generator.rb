class StylesheetsGenerator < Rails::Generator::Base

  def manifest
    record do |m|
      m.directory File.join('public/stylesheets')

      # Include default stylesheets
      stylesheets = ["ie7", "ie6"]

      # Add stylesheets for each controller
      controllers = Dir::open("#{RAILS_ROOT}/app/controllers").entries
      controllers.reject! { |x| /^\./ =~ x }
      controllers.each do |controller|
        controller.gsub!(/_controller.rb/,'')
        controller.gsub!(/.rb/,'')
        stylesheets << controller
      end

      # Create stylesheets (if not present)
      stylesheets.each do |stylesheet|
        if !File.exist?("#{RAILS_ROOT}/public/stylesheets/#{stylesheet}.css")
          m.template 'template.css', File.join('public/stylesheets', "#{stylesheet}.css")
        end
      end
    end
  end

end
