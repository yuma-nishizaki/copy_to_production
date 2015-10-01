require "copy_to_production/version"

module CopyToProduction
  class Copier
    def initialize(args)
      @adapter = args[:adapter]
      @encoding = args[:encoding]
      @database = args[:database]
      @pool = args[:pool]
      @username = args[:username]
      @password = args[:password]
      @host = args[:host]
      @port = args[:port]
      @has_attached_file_hash = args[:has_attached_file_hash]
      @establish_connection_hash = args[:establish_connection_hash] || {:adapter => @adapter,
                                                                        :encoding => @encoding,
                                                                        :database => @database,
                                                                        :pool => @pool,
                                                                        :username => @username,
                                                                        :password => @password,
                                                                        :host => @host,
                                                                        :port => @port}
    end
    
    def copy_to_production(objects_to_be_copied)
      images_to_be_copied = Hash.new
      objects_to_be_copied.each do |object|
        images_to_be_copied["#{object.class}-#{object.id}"] = get_images_to_be_copied(object)
      end

      with_production_database do
        with_production_attachment_settings(objects_to_be_copied.first) do
          save_objects(objects_to_be_copied, images_to_be_copied)
        end
      end
    end
    
    private
    def save_objects(objects, images)
      objects_to_save = objects.map do |object|
        new_object(object:object, images:images)
      end
      ActiveRecord::Base.transaction do  
        saved_objs = objects_to_save.map do |obj| 
          obj.save!
          obj
        end
        saved_objs
      end 
    end
  
    def with_production_database
      rails_env = Rails.env
      original_config = ActiveRecord::Base.configurations[rails_env] ||
                        Rails.application.config.database_configuration[rails_env]
      #switch DB 
      ActiveRecord::Base.establish_connection @establish_connection_hash
      yield
    ensure
      ActiveRecord::Base.establish_connection(original_config)# back to original
    end
  
    def with_production_attachment_settings(object)#TODO:objectsで受けてすべてのobjectsに対して設定変更する必要あり
      object_class = object.class
      object_class_has_attached_file = object_class.respond_to?("attachment_definitions")
      #change attachment settings to prodution
      if object_class_has_attached_file
        original_attachment_config = object_class.attachment_definitions
        paperclip_column_names = get_paperclip_column_names(object)
        paperclip_column_names.each do |item|
          object_class.has_attached_file item.to_sym, @has_attached_file_hash
        end
      end
      yield
    ensure
      #make attachment settings back to original
      if object_class_has_attached_file
        paperclip_column_names.each do |item|
          item_sym = item.to_sym
          style_hash = original_attachment_config.fetch(item_sym)
          object_class.has_attached_file item_sym, style_hash
        end
      end
    end
    
    class PaperclipedClass
      def initialize(object)
        @class = object.class
        @original_attachment_definitions = @class.attachment_definitions
      end
      
      def change_attachment_settings
        #change attachment settings to prodution
        if @class.respond_to?("attachment_definitions")
          get_paperclip_column_names.each do |item|
            @class.has_attached_file item.to_sym, @has_attached_file_hash
          end
        end
      end

      def back_attachment_settings_to_original
        if @class.respond_to?("attachment_definitions")
          get_paperclip_column_names.each do |item|
            item_sym = item.to_sym
            style_hash = @original_attachment_definitions.fetch(item_sym)
            @class.has_attached_file item_sym, style_hash
          end
        end
      end
      
      def get_paperclip_column_names
        paperclip_column_names_with_suffix = @class.column_names.select{|item| item.include?("_file_name")}
        paperclip_column_names_with_suffix.map{|fnc| fnc.sub(/_file_name/, '')}
      end
      
    end
  
    def get_paperclip_column_names(object)
      paperclip_column_names_with_suffix = object.class.column_names.select{|item| item.include?("_file_name")}
      paperclip_column_names_with_suffix.map{|fnc| fnc.sub(/_file_name/, '')}
    end
  
    def new_object(args={})
      object,images  = args.fetch(:object), args.fetch(:images)                                                
      new_object = new_object_without_id(object)

      images.fetch("#{object.class}-#{object.id}").each do |image_name, image|
        new_object.send(image_name).assign(image)
      end
      new_object
    end
  
    def new_object_without_id(object)
      object_class, attrs = object.class, object.attributes
      attrs.delete("id") #delete id
      attrs.delete_if{|item| item.include?("_id")} #delete foreign keys
      object_class.new(attrs)
    end
    
    def get_images_to_be_copied(object)
      images_to_be_copied = Hash.new
      get_paperclip_column_names(object).each do |item|
        images_to_be_copied[item] = object.send(item)
      end
      images_to_be_copied
    end
  end
end
