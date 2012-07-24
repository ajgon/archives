require 'spec_helper'
require 'formtastic'
require 'spec_mocks'
require 'rspec_tag_matchers'

describe 'admin_bootstrap extensions' do

  describe 'Gem' do

    it 'should not throw deprecation warning for Gem.available?' do
      buffer = StringIO.new
      $stderr = buffer
      Gem.available?('admin-bootstrap')
      $stderr = STDERR
      buffer.rewind
      result = buffer.read
      buffer.close
      result.should_not match(/Gem.available\? is deprecated, use Specification::find_by_name./)
    end

  end

  describe 'FormtasticBootstrap' do

    include FormtasticSpecHelper

    before(:each) do
      @item = mock(Item)
      @item.stub!(:class).and_return(::Item)
      @item.stub!(:id).and_return(nil)
      @item.stub!(:title).and_return('Title')
      @item.stub!(:body).and_return('Body')
      @item.stub!(:to_key).and_return(nil)
      ::Item.stub!(:content_columns).and_return([mock('column', :name => 'title'), mock('column', :name => 'body'), mock('column', :name => 'created_at')])
      @output_buffer = ''
    end

    it 'should return good inputs HTML' do
      concat(semantic_form_for(@item) do |builder|
        @inputs_output = concat(builder.inputs)
      end)

      output_buffer.should have_tag("form li.input.required.string")
      output_buffer.should have_tag("form li#item_body_input")
      output_buffer.should have_tag("form li#item_title_input")
      output_buffer.should have_tag("form li label", /Title/)
      output_buffer.should have_tag("form li label", /Body/)
      output_buffer.should have_tag("form li label.label[@for='item_title']")
      output_buffer.should have_tag("form li label.label[@for='item_body']")
      output_buffer.should have_tag("form li input#item_title")
      output_buffer.should have_tag("form li input#item_body")
      output_buffer.should have_tag("form li input[@name='item[title]']")
      output_buffer.should have_tag("form li input[@name='item[body]']")

    end

  end

  describe 'ActiveRecord' do

    AdminBootstrap::Plugins::Base.disable!

    it 'should return empty admin_columns' do

      tmp1 = mock(Object)
      tmp1.stub!(:schema_cache).and_return(tmp1)
      tmp1.stub!(:columns).and_return({'items' => [
          mock('column', :dup => mock('dupcolumn', :name => 'title', 'primary=' => nil)),
          mock('column', :dup => mock('dupcolumn', :name => 'body', 'primary=' => nil)),
          mock('column', :dup => mock('dupcolumn', :name => 'created_at', 'primary=' => nil))
      ]})

      ::Item.stub!(:table_name).and_return('items')
      ::Item.stub!(:primary_key).and_return('id')
      ::Item.stub!(:connection).and_return(tmp1)

      ::Item.admin_columns.should eq({})

    end

  end

end