require 'spec_helper'
describe 'realmd' do
  context 'with default values for all parameters' do
    it { should contain_class('realmd') }
  end
end
