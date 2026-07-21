class Depository < ApplicationRecord
  include Accountable

  SUBTYPES = {
    "checking" => { short: "Checking", long: "Checking" },
    "savings" => { short: "Savings", long: "Savings" },
    "hsa" => { short: "HSA", long: "Health Savings Account" },
    "cd" => { short: "CD", long: "Certificate of Deposit" },
    "money_market" => { short: "MM", long: "Money Market" },
    "livret_a" => { short: "Livret A", long: "Livret A" },
    "ldds" => { short: "LDDS", long: "Livret de Développement Durable et Solidaire" },
    "livret_jeune" => { short: "Livret Jeune", long: "Livret Jeune" },
    "lep" => { short: "LEP", long: "Livret d'Épargne Populaire" },
    "assurance_vie" => { short: "Assurance-vie", long: "Assurance-vie (fonds euros)" }
  }.freeze

  # Livrets d'épargne réglementée : taux légaux par défaut et plafonds fixés par
  # la loi française. Le taux peut être surchargé par compte (colonne
  # `interest_rate`) car il change périodiquement par décret ; le plafond reste
  # fixe. Les intérêts sont exonérés d'impôt sur le revenu et de prélèvements
  # sociaux.
  REGULATED_SAVINGS = {
    "livret_a" => { rate: 0.024, cap: 22_950, tax_free: true },
    "ldds" => { rate: 0.024, cap: 12_000, tax_free: true },
    "livret_jeune" => { rate: 0.03, cap: 1_600, tax_free: true },
    "lep" => { rate: 0.035, cap: 10_000, tax_free: true }
  }.freeze

  class << self
    def display_name
      "Cash"
    end

    def color
      "#875BF7"
    end

    def classification
      "asset"
    end

    def icon
      "landmark"
    end
  end
end
