require 'spec_helper'
require 'wc3_protocol'

#----------------------------------------------------------------------------------------------------

RSpec.describe Wc3Protocol do
  it "has a version number" do
    expect(Wc3Protocol::VERSION).not_to be nil
  end
end

#----------------------------------------------------------------------------------------------------
