require "test_helper"

class RegulatedSavingsInterestJobTest < ActiveJob::TestCase
  setup do
    @livret_a = Account.create! \
      family: families(:dylan_family),
      name: "Livret A",
      balance: 12_000,
      currency: "EUR",
      accountable: Depository.create!,
      subtype: "livret_a"

    @checking = Account.create! \
      family: families(:dylan_family),
      name: "Compte courant",
      balance: 5_000,
      currency: "EUR",
      accountable: Depository.create!,
      subtype: "checking"
  end

  test "posts monthly interest on regulated savings accounts" do
    RegulatedSavingsInterestJob.perform_now(date: Date.new(2026, 1, 15))

    interest_entries = interest_entries_for(@livret_a)
    assert_equal 1, interest_entries.count
    assert_equal(-24.0, interest_entries.first.entry.amount.to_f) # 12_000 * 0.024 / 12
  end

  test "does not post interest for non-regulated subtypes" do
    RegulatedSavingsInterestJob.perform_now(date: Date.new(2026, 1, 15))

    assert_equal 0, interest_entries_for(@checking).count
  end

  test "is idempotent within the same month" do
    RegulatedSavingsInterestJob.perform_now(date: Date.new(2026, 1, 5))
    RegulatedSavingsInterestJob.perform_now(date: Date.new(2026, 1, 25))

    assert_equal 1, interest_entries_for(@livret_a).count
  end

  test "posts again in a following month" do
    RegulatedSavingsInterestJob.perform_now(date: Date.new(2026, 1, 15))
    RegulatedSavingsInterestJob.perform_now(date: Date.new(2026, 2, 15))

    assert_equal 2, interest_entries_for(@livret_a).count
  end

  private
    def interest_entries_for(account)
      Transaction.interest.with_entry.where(entries: { account_id: account.id })
    end
end
