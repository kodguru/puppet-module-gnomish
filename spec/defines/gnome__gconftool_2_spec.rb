require 'spec_helper'
describe 'gnomish::gnome::gconftool_2' do
  let(:title) { '/desktop/rspec' }

  describe 'with defaults for all parameters' do
    it 'should fail' do
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /(expects a value for|Must pass value to)/)
    end
  end

  describe 'with value set to valid string <testing>' do
    let(:params) { { :value => 'testing' } }

    it { should compile.with_all_deps }

    it do
      should contain_exec('gconftool-2 /desktop/rspec').with({
        'command' => 'gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults --type string --set \'/desktop/rspec\' \'testing\'',
        'unless'  => 'test "$(gconftool-2 --get /desktop/rspec)" == "testing"',
        'path'    => '/bin:/sbin:/usr/bin:/usr/sbin',
      })
    end
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) do
      {
        #:fact => 'value',
      }
    end
    let(:mandatory_params) do
      {
        :value => 'value',
      }
    end

    validations = {
      'absolute_path' => {
        :name    => %w(config),
        :valid   => %w(/absolute/filepath /absolute/directory/),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'is not an absolute path',
      },
      'string' => {
        :name    => %w(key),
        :valid   => ['string'],
        :invalid => [%w(array), { 'ha' => 'sh' }, 3, 2.42, true, false],
        :message => 'is not a string',
      },
      'stringified value' => {
        :name    => %w(value),
        :valid   => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false],
        :invalid => [],
        :message => 'is not a string',
      },
      'regex desktop' => {
        :name    => %w(type),
        :valid   => %w(auto bool boolean int integer float string),
        :invalid => [%w(array), { 'ha' => 'sh' }, 3, 2.42, true, false],
        :message => 'gnomish::gnome::gconftool_2::type must be one of <bool>, <int>, <float>, <string> or <auto> and is set to',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => valid, }].reduce(:merge) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => invalid, }].reduce(:merge) }
            it 'should fail' do
              expect { should contain_class(subject) }.to raise_error(Puppet::Error, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end