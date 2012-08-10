require 'spec_helper'

share_examples_for 'an action with twitter bootstrap included' do
  render_views

  it 'checks that twitter bootstrap stylesheets are included' do
    action
    all('link').collect { |link| File.basename(link[:href]) }.grep(/^bootstrap/).should have(2).items
  end

  it 'checks that twitter bootstrap javascript is included' do
    action
    all('script[src]').collect { |script| File.basename(script[:src]) }.grep(/^bootstrap/).should have(1).item
  end

end

share_examples_for 'an action with jquery.dataTables included' do
  render_views

  it 'checks if jquery.dataTables and its plugins are included' do
    action
    all('script[src]').collect { |script| File.basename(script[:src]) }.grep(/jquery\.dataTables/).should have(4).items
  end

end

share_examples_for 'an action with google prettify included' do
  render_views

  it 'checks that google prettify stylesheets are included' do
    action
    all('link').collect { |link| File.basename(link[:href]) }.grep(/^prettify/).should have(1).items
  end

  it 'checks that google prettify javascript is included' do
    action
    all('script[src]').collect { |script| File.basename(script[:src]) }.grep(/^prettify/).should have(1).item
  end

end

shared_examples_for "admin resource" do

  def incorrect_data
    (model = described_class.extract_resource).should be_a_descendant_of(ActiveRecord::Base)

    field_with_presence_validation = model.validators.find {|v| v.kind_of?(ActiveModel::Validations::PresenceValidator)}
    unless field_with_presence_validation
      pending "add some tests for #update action with incorrect data for #{described_class.controller_path}"
      {}
    else
      field_with_presence_validation = field_with_presence_validation.attributes.first
      build(model.to_s.underscore.to_sym, field_with_presence_validation => '').attributes.slice(*(model.accessible_attributes.to_a))
    end
  end

  def correct_data
    (model = described_class.extract_resource).should be_a_descendant_of(ActiveRecord::Base)
    build(model.to_s.underscore.to_sym).attributes.slice(*(model.accessible_attributes.to_a))
  end

  def self.passes_attributes
    it "passes attributes to instance" do
      attr.each do |key|
        assigns[:resource][key].should eql(attr[key])
      end
    end
  end

  def self.fetches_instance
    it "fetches user instance" do
      (model = described_class.extract_resource).should be_a_descendant_of(ActiveRecord::Base)
      assigns[:resource].should be_a(model)
    end
  end

  def self.fetches_resource
    it "fetches instance" do
      assigns[:resource].should eq(resource)
    end
  end

  def self.renders_show
    it "should render template 'show'" do
      render_template :show
    end
  end

  def self.renders_edit
    it "should render template 'edit'" do
      render_template :edit
    end
  end

  def self.renders_new
    it "should render template 'new'" do
      render_template :new
    end
  end

  def self.redirects_to_show
    it "redirects to resource show page" do
      response.should redirect_to(:action => :show, :id => assigns[:resource].id)
    end
  end

  describe '#index' do
    render_views

    it_should_behave_like 'an action with twitter bootstrap included' do
      let(:action) { visit '/' + described_class.controller_path }
    end

    it_should_behave_like 'an action with jquery.dataTables included' do
      let(:action) { visit '/' + described_class.controller_path }
    end

    it_should_behave_like 'an action with google prettify included' do
      let(:action) { visit '/' + described_class.controller_path }
    end

    it "should render template 'index'" do
      render_template :index
    end

    it 'should render base object table' do
      (model = described_class.extract_resource).should be_a_descendant_of(ActiveRecord::Base)

      visit '/' + described_class.controller_path
      page.should have_selector('table.table.table-bordered.table-striped')
      page.should have_selector('thead')
      page.should have_selector('tbody')
      page.should have_selector('tfoot')
      all('thead tr th').size.should eq(model.columns(:admin => true).size + 1)
    end

    describe 'dataTables' do
      before(:all) do
        (@model = described_class.extract_resource).should be_a_descendant_of(ActiveRecord::Base)
        @columns = @model.column_names(:admin => true)
        @count = 12

        (@count - @model.count).times do
          create(@model.to_s.underscore.to_sym)
        end

        columns_num = @model.columns.size + 2
        @default_request = {
            :format => 'json',
            :bRegex => 'false',
            :iColumns => columns_num.to_s,
            :iDisplayLength => '10',
            :iDisplayStart => '0',
            :iSortCol_0 => '0',
            :iSortingCols => '1',
            :sColumns => '',
            :sEcho => '1',
            :sSearch => '',
            :sSortDir_0 => 'asc'
        }
        columns_num.times do |i|
          i = i.to_s
          @default_request[('bRegex_' + i).to_sym] = 'false'
          @default_request[('bSearchable_' + i).to_sym] = 'true'
          @default_request[('bSortable_' + i).to_sym] = 'true'
          @default_request[('mDataProp_' + i).to_sym] = i
          @default_request[('sSearch_' + i).to_sym] = ''
        end
        @default_request[:bSortable_0] = 'false'
        @default_request[:bSearchable_0] = 'false'
        @default_request[('bSortable_' + (columns_num - 1).to_s).to_sym] = 'false'
        @default_request[('bSearchable_' + (columns_num - 1).to_s).to_sym] = 'false'
        @expected_behaviour = {:order => @model.column_names(:admin => true).first.to_s + ' asc'}
      end

      before(:each) do
        @params = @default_request.dup
      end

      let(:check_response_for_dataTables) do
        @count = @model.count
        iDisplayLength = @params[:iDisplayLength].to_i < 0 ? @count : @params[:iDisplayLength].to_i
        @expected_behaviour.merge!(:offset => @params[:iDisplayStart], :limit => iDisplayLength)

        get :index, @params
        json = parse_json(@response.body)
        expected_count = @model.count(@expected_behaviour)

        json['iTotalRecords'].should eq(@count)
        json['iTotalDisplayRecords'].should eq(expected_count)
        json['sEcho'].should eq(@params[:sEcho])

        results = @model.all(@expected_behaviour)
        json['aaData'].should have([ iDisplayLength, results.size ].min ).items

        results.each.with_index do |result, r|
          @columns.each.with_index do |column, c|
            json['aaData'][r][c.to_s].to_s.should eq(AdminBootstrap::DataTable.parse_value(result, column))
          end
          json['aaData'][r]['DT_RowId'].should eq(result.id.to_s)
        end
      end

      it 'should receive JSON encoded data for default dataTables request' do
        check_response_for_dataTables
      end

      it 'should contain button with options for each row of dataTable' do
        get :index, @params
        json = parse_json(@response.body)
        last_column_index = @columns.size.to_s
        json['aaData'].each do |result|
          result[last_column_index].should match(Regexp.new("('|\")/admin/[^\"']+/[0-9]+/edit('|\")")) unless @model.admin_options[:disabled_actions] and @model.admin_options[:disabled_actions][:value].include?(:edit)
          result[last_column_index].should match(Regexp.new("('|\")/admin/[^\"']+/[0-9]+('|\")")) unless @model.admin_options[:disabled_actions] and @model.admin_options[:disabled_actions][:value].include?(:show)
          result[last_column_index].should match(/data-method=('|")delete('|")/) unless @model.admin_options[:disabled_actions] and @model.admin_options[:disabled_actions][:value].include?(:destroy)
          result[last_column_index].should match(/data-toggle=('|")dropdown('|")/)
        end
      end

      it 'should receive second page of results with length of the table equal to 10' do
        @params[:iDisplayStart] = 10

        check_response_for_dataTables
      end

      it 'should receive first and only page of results with length of the table equal to 25' do
        @params[:iDisplayLength] = 25

        check_response_for_dataTables
      end

      it 'should receive all results in one page' do
        @params[:iDisplayLength] = -1

        check_response_for_dataTables
      end

      it 'should filter search results' do
        (model = described_class.extract_resource).should be_a_descendant_of(ActiveRecord::Base)

        column = (model.columns(:admin => true) & model.columns).find {|c| c.type == :string or c.type == :text}

        if column
          column_name = column.name

          @params[:sSearch] = search = model.all.collect do |m|
            m.send(column_name) unless m.send(column_name).blank?
          end.first

          @expected_behaviour = {:conditions => "`" + (@columns & @model.column_names).join("` LIKE '%#{search}%' OR `") + "` LIKE '%#{search}%'"}

          check_response_for_dataTables
        end
      end

      it 'should sort by third column ascending and then by first column descending' do
        admin_columns = @model.column_names(:admin => true)
        good_columns = admin_columns & @model.column_names
        @params[:iSortingCols] = 2
        @params[:iSortCol_0] = admin_columns.index(good_columns[2])
        @params[:iSortCol_1] = admin_columns.index(good_columns[0])
        @params[:sSortDir_0] = 'asc'
        @params[:sSortDir_1] = 'desc'
        @expected_behaviour = {:order => "`#{good_columns[2]}` ASC, `#{good_columns[0]}` DESC"}
        check_response_for_dataTables
      end
    end

  end

  context 'with existing resource' do
    before { subject }

    disabled_actions = described_class.extract_resource.admin_options[:disabled_actions] || {:value => []}

    let(:resource) do
      (model = described_class.extract_resource).should be_a_descendant_of(ActiveRecord::Base)
      create(model.to_s.underscore.to_sym)
    end

    unless disabled_actions[:value].include?(:show)
      describe '#show' do
        subject { get :show, :id => resource.id }

        renders_show
        fetches_resource
      end
    end

    unless disabled_actions[:value].include?(:edit)
      describe "#edit" do
        subject { get :edit, :id => resource.id }

        renders_edit
        fetches_resource
      end
    end

    unless disabled_actions[:value].include?(:update)
      describe "#update" do
        subject { put :update, :id => resource.id, described_class.extract_resource.to_s.underscore.to_sym => attr }

        context "incorrect data" do

          let(:attr) { incorrect_data }

          fetches_instance
          passes_attributes

          it "does not save changed instance" do
            assigns[:resource].changes.should_not be_empty
          end

          renders_edit

        end

        context "correct data" do
          let(:attr) { correct_data }

          fetches_instance
          passes_attributes

          it "saves changed instance" do
            assigns[:resource].changes.should be_empty
          end

          redirects_to_show

          it "assigns flash message" do
            (model = described_class.extract_resource).should be_a_descendant_of(ActiveRecord::Base)
            flash[:notice].should eq("#{model.to_s} was successfully updated.")
          end
        end
      end
    end

    unless disabled_actions[:value].include?(:destroy)
      describe '#destroy' do
        render_views

        before(:all) do
          (model = described_class.extract_resource).should be_a_descendant_of(ActiveRecord::Base)
          model.destroy_all
        end

        it 'should destroy specified records' do
          ids = []
          (model = described_class.extract_resource).should be_a_descendant_of(ActiveRecord::Base)
          5.times do
            ids.push create(model.to_s.underscore.to_sym).id
          end
          size = model.count

          destroy_ids = ids.shuffle[0..1]

          delete :destroy, :id => destroy_ids.join(','), :format => 'json'

          model.count.should eq(size - 2)
          model.all.collect(&:id).should_not include(destroy_ids)
          json = parse_json(@response.body)
          json['code'].should eq('SUCCESS')
          json['message'].should_not be_empty
        end

        it 'should destroy given record' do
          rows = resource.class.count

          delete :destroy, :id => resource.id

          resource.class.count.should eq(rows - 1)
        end

      end
    end

  end

  context "without existing resource" do
    before { subject }

    disabled_actions = described_class.extract_resource.admin_options[:disabled_actions] || {:value => []}

    unless disabled_actions[:value].include?(:new)
      describe "#new" do
        let(:subject) { get :new }
        renders_new
      end
    end

    unless disabled_actions[:value].include?(:create)
      describe "#create" do
        subject { post :create, described_class.extract_resource.to_s.underscore.to_sym => attr }

        context "incorrect data" do
          let(:attr) { incorrect_data }

          it "does not create new resource" do
            assigns[:resource].should_not be_persisted
          end

          renders_new
        end

        context "correct data" do
          let(:attr) { correct_data }
          passes_attributes

          it "creates new record" do
            assigns[:resource].should be_persisted
          end

          redirects_to_show

          it "assigns flash message" do
            (model = described_class.extract_resource).should be_a_descendant_of(ActiveRecord::Base)
            flash[:notice].should eq("#{model.to_s} was successfully created!")
          end

        end
      end
    end
  end

end