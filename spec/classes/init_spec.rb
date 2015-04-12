require 'spec_helper'
describe 'cta_systemcfg' do

  context 'with defaults for all parameters' do
    it { should contain_class('cta_systemcfg') }
  end
end
