# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'objective_form/version'

Gem::Specification.new do |s|
  s.name          = "objective_form"
  s.version       = ObjectiveForm::VERSION
  s.authors       = ["stevo"]
  s.email         = ["blazejek@gmail.com"]
  s.homepage      = "https://github.com//objective_form"
  s.summary       = "Form objects with nested_form support"
  s.description   = "Objective form is for whoever miss dynamic nested fields adding in form object using nested_form gem by Ryan Bates. Beside that it is lightweight abstraction of form objects for Rails."
  s.files         = `git ls-files app lib`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.rubyforge_project = '[none]'
end
