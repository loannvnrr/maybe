class SetFrenchFamilyDefaults < ActiveRecord::Migration[7.2]
  def change
    change_column_default :families, :currency, from: "USD", to: "EUR"
    change_column_default :families, :date_format, from: "%m-%d-%Y", to: "%d/%m/%Y"
    change_column_default :families, :locale, from: "en", to: "fr"
    change_column_default :families, :country, from: "US", to: "FR"
  end
end
