objective_form
==============

Form objects compatible with nested_form

Setup
-----

Just place `gem 'objective_form'` in your Gemfile and run _bundle install_ command

Usage
-----

To use objective form, just inherit from `ObjectiveForm::Base`, i.e.

```ruby
class MyFormObject < ObjectiveForm::Base
end
```    
    
Defining attributes is rather self-explanatory. You can use validations as well.

```ruby
class MyFormObject < ObjectiveForm::Base
  attribute :name, String 
  attribute :user_id, Integer      
  attribute :product_ids, Array
  
  validates :name, :presence => true
end
```

Calling `save` on form object, checks if object is valid, and then calls `persist!` method, you need to implement yourself, i.e.

```ruby
class MyFormObject < ObjectiveForm::Base  
  attribute :user_id, Integer      
  attribute :product_ids, Array
  #...
  
  def persist!
    user = User.find(user_id)
    Product.where(:id => product_ids).each do |product|
      user.observe_product!(product)
    end
  end
end
```
    
nested_form
-----------

To use nested_form, you need to define pseudo `has_many` relation on form object, i.e.

```ruby
class MyFormObject < ObjectiveForm::Base 
  has_many :emails, ObjectiveForm::PseudoRecord.new(:email => String)
end
```    

From now on, it is a matter of passing the same `ObjectiveForm::PseudoRecord` object as `:model_object` attribute of `link_to_add` helper, i.e.

```erb
<%= nested_form_for MyFormObject.new, :url => user_emails_path do |f| %>
  <%= f.fields_for :emails do |email_form| %>
    <div class="item">
      <%= email_form.text_field :email %>
      <%= email_form.link_to_remove "Remove this email"%>
    </div>
  <% end %>

  <%= f.link_to_add "Add an email", :emails, :model_object => ObjectiveForm::PseudoRecord.new(:email => String).new %>    
    
  <%= f.submit "Save"%>        
<% end %>
```    
