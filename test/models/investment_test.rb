require "test_helper"

class InvestmentTest < ActiveSupport::TestCase
  test "pea is a valid investment subtype" do
    assert Investment::SUBTYPES["pea"]
  end

  test "pea versement cap is 150000" do
    assert_equal 150_000, Investment::PEA_VERSEMENT_CAP
  end
end
