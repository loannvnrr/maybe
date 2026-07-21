# Runs monthly (see config/schedule.yml) to post the interest earned on French
# regulated savings accounts (Livret A, LDDS, Livret Jeune, LEP) since these
# products don't sync with a bank connection and don't compute interest on their own.
#
# Interest is approximated as: end-of-month balance x (annual rate / 12).
# This is a simplification of the official "quinzaines" calculation method used
# by French banks, which is considered unnecessary precision for personal tracking.
class RegulatedSavingsInterestJob < ApplicationJob
  queue_as :scheduled

  def perform(date: Date.current)
    accounts = Account.where(
      status: "active",
      accountable_type: "Depository",
      subtype: Depository::REGULATED_SAVINGS.keys
    )

    accounts.find_each do |account|
      post_interest(account, date)
    end
  end

  private
    def post_interest(account, date)
      return if already_posted?(account, date)

      info = Depository::REGULATED_SAVINGS.fetch(account.subtype)
      interest = (account.balance.to_d * info[:rate] / 12).round(2)
      return if interest <= 0

      entry = account.entries.create!(
        date: date,
        name: "Intérêts #{account.long_subtype_label} (net d'impôt)",
        amount: -interest,
        currency: account.currency,
        entryable: Transaction.new(kind: "interest")
      )

      entry.sync_account_later
    end

    def already_posted?(account, date)
      Transaction.interest
                 .with_entry
                 .where(entries: { account_id: account.id, date: date.beginning_of_month..date.end_of_month })
                 .exists?
    end
end
