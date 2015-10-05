# models
class User < ActiveRecord::Base
end
class Product < ActiveRecord::Base
  has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
end
class Book < ActiveRecord::Base
  has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
end

#migrations
class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table(:users) {|t| t.string :name; t.integer :age}
    create_table(:products) {|t| t.string :name; }
    add_attachment :products, :image
    create_table(:books) {|t| t.string :name; }
    add_attachment :books, :image
  end
end
ActiveRecord::Migration.verbose = false
CreateAllTables.up
