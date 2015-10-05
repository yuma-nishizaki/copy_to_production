require 'spec_helper'

describe CopyToProduction do
  it 'has a version number' do
    expect(CopyToProduction::VERSION).not_to be nil
  end

  describe CopyToProduction::Copier do
    describe CopyToProduction::Copier::PaperclipedClass do
      describe "initialize" do
        context "when the class is not paperclip class" do
          it { expect{CopyToProduction::Copier::PaperclipedClass.new(User, {})}.to raise_error }
        end
        context "when the class is a paperclip class" do
          it { expect{CopyToProduction::Copier::PaperclipedClass.new(Product, {})}.not_to raise_error }
        end
      end
      describe "change_attachment_settings and back_attachment_settings_to_original" do
        let(:pcc){CopyToProduction::Copier::PaperclipedClass.new(Product, {:styles => { :medium => "200x200>", :thumb => "100x100>" }})}
        it {
          expect(Product.attachment_definitions).to eq({:image=>{:styles=>{:medium=>"300x300>", :thumb=>"100x100>"}, :default_url=>"/images/:style/missing.png"}})
          pcc.change_attachment_settings
          expect(Product.attachment_definitions).to eq({:image=>{:styles => { :medium => "200x200>", :thumb => "100x100>" }}})
          pcc.back_attachment_settings_to_original
          expect(Product.attachment_definitions).to eq({:image=>{:styles=>{:medium=>"300x300>", :thumb=>"100x100>"}, :default_url=>"/images/:style/missing.png"}})
        }
      end
    end
  end
  describe "with_production_attachment_settings" do
    let(:cp){CopyToProduction::Copier.new(has_attached_file_hash:{:styles => { :medium => "200x200>", :thumb => "100x100>" }})}
    context "when single object" do
      let(:product){Product.create}
      it{
        expect(product.class.attachment_definitions).to eq({:image=>{:styles=>{:medium=>"300x300>", :thumb=>"100x100>"}, :default_url=>"/images/:style/missing.png"}})
        cp.send("with_production_attachment_settings", [product]) do
          expect(product.class.attachment_definitions).to eq({:image=>{:styles => { :medium => "200x200>", :thumb => "100x100>" }}})
        end
      }
    end    
    context "when multiple objects" do
      let(:product){Product.create}
      let(:book){Book.create}
      it{
        expect(product.class.attachment_definitions).to eq({:image=>{:styles=>{:medium=>"300x300>", :thumb=>"100x100>"}, :default_url=>"/images/:style/missing.png"}})
        expect(book.class.attachment_definitions).to eq({:image=>{:styles=>{:medium=>"300x300>", :thumb=>"100x100>"}, :default_url=>"/images/:style/missing.png"}})
        cp.send("with_production_attachment_settings", [product, book]) do
          expect(product.class.attachment_definitions).to eq({:image=>{:styles => { :medium => "200x200>", :thumb => "100x100>" }}})
          expect(book.class.attachment_definitions).to eq({:image=>{:styles => { :medium => "200x200>", :thumb => "100x100>" }}})
        end
      }
    end    
  end
end
