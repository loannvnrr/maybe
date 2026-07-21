require "test_helper"

class DepositoryTest < ActiveSupport::TestCase
  test "regulated savings subtypes have a statutory rate and cap" do
    %w[livret_a ldds livret_jeune lep].each do |subtype|
      info = Depository::REGULATED_SAVINGS[subtype]
      assert info, "expected #{subtype} to be a regulated savings subtype"
      assert info[:rate] > 0
      assert info[:cap] > 0
      assert info[:tax_free]
    end
  end

  test "assurance_vie is not a regulated savings subtype" do
    assert_nil Depository::REGULATED_SAVINGS["assurance_vie"]
    assert Depository::SUBTYPES["assurance_vie"]
  end

  test "account cap is nil for non-regulated subtypes" do
    account = Account.create! \
      family: families(:dylan_family),
      name: "Compte courant",
      balance: 100,
      currency: "EUR",
      accountable: Depository.create!(),
      subtype: "checking"

    assert_nil account.regulated_savings_cap
    assert_not account.regulated_savings_cap_reached?
  end

  test "account cap reached when balance meets the statutory cap" do
    account = Account.create! \
      family: families(:dylan_family),
      name: "Livret A",
      balance: 22_950,
      currency: "EUR",
      accountable: Depository.create!(),
      subtype: "livret_a"

    assert_equal 22_950, account.regulated_savings_cap
    assert account.regulated_savings_cap_reached?
  end

  test "account cap not reached when balance is below the statutory cap" do
    account = Account.create! \
      family: families(:dylan_family),
      name: "Livret A",
      balance: 1_000,
      currency: "EUR",
      accountable: Depository.create!(),
      subtype: "livret_a"

    assert_not account.regulated_savings_cap_reached?
  end
end
