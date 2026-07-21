class UI::Account::BalanceReconciliation < ApplicationComponent
  attr_reader :balance, :account

  def initialize(balance:, account:)
    @balance = balance
    @account = account
  end

  def reconciliation_items
    case account.accountable_type
    when "Depository", "OtherAsset", "OtherLiability"
      default_items
    when "CreditCard"
      credit_card_items
    when "Investment"
      investment_items
    when "Loan"
      loan_items
    when "Property", "Vehicle"
      asset_items
    when "Crypto"
      crypto_items
    else
      default_items
    end
  end

  private

    def default_items
      items = [
        item("default", "start_balance", balance.start_balance_money, :start),
        item("default", "net_cash_flow", net_cash_flow, :flow)
      ]

      if has_adjustments?
        items << item("default", "end_balance", end_balance_before_adjustments, :subtotal)
        items << item("default", "adjustments", total_adjustments, :adjustment)
      end

      items << item("default", "final_balance", balance.end_balance_money, :final)
      items
    end

    def credit_card_items
      items = [
        item("credit_card", "start_balance", balance.start_balance_money, :start),
        item("credit_card", "charges", balance.cash_outflows_money, :flow),
        item("credit_card", "payments", balance.cash_inflows_money * -1, :flow)
      ]

      if has_adjustments?
        items << item("credit_card", "end_balance", end_balance_before_adjustments, :subtotal)
        items << item("credit_card", "adjustments", total_adjustments, :adjustment)
      end

      items << item("credit_card", "final_balance", balance.end_balance_money, :final)
      items
    end

    def investment_items
      items = [
        item("investment", "start_balance", balance.start_balance_money, :start)
      ]

      # Change in brokerage cash (includes deposits, withdrawals, and cash from trades)
      items << item("investment", "brokerage_cash_change", net_cash_flow, :flow)

      # Change in holdings from trading activity
      items << item("investment", "holdings_trading_change", net_non_cash_flow, :flow)

      # Market price changes
      items << item("investment", "holdings_market_change", balance.net_market_flows_money, :flow)

      if has_adjustments?
        items << item("investment", "end_balance", end_balance_before_adjustments, :subtotal)
        items << item("investment", "adjustments", total_adjustments, :adjustment)
      end

      items << item("investment", "final_balance", balance.end_balance_money, :final)
      items
    end

    def loan_items
      items = [
        item("loan", "start_principal", balance.start_balance_money, :start),
        item("loan", "net_principal_change", net_non_cash_flow, :flow)
      ]

      if has_adjustments?
        items << item("loan", "end_principal", end_balance_before_adjustments, :subtotal)
        items << item("loan", "adjustments", balance.non_cash_adjustments_money, :adjustment)
      end

      items << item("loan", "final_principal", balance.end_balance_money, :final)
      items
    end

    def asset_items # Property/Vehicle
      items = [
        item("asset", "start_value", balance.start_balance_money, :start),
        item("asset", "net_value_change", net_total_flow, :flow)
      ]

      if has_adjustments?
        items << item("asset", "end_value", end_balance_before_adjustments, :subtotal)
        items << item("asset", "adjustments", total_adjustments, :adjustment)
      end

      items << item("asset", "final_value", balance.end_balance_money, :final)
      items
    end

    def crypto_items
      items = [
        item("crypto", "start_balance", balance.start_balance_money, :start)
      ]

      items << item("crypto", "buys", balance.cash_outflows_money * -1, :flow) if balance.cash_outflows != 0
      items << item("crypto", "sells", balance.cash_inflows_money, :flow) if balance.cash_inflows != 0
      items << item("crypto", "market_changes", balance.net_market_flows_money, :flow) if balance.net_market_flows != 0

      if has_adjustments?
        items << item("crypto", "end_balance", end_balance_before_adjustments, :subtotal)
        items << item("crypto", "adjustments", total_adjustments, :adjustment)
      end

      items << item("crypto", "final_balance", balance.end_balance_money, :final)
      items
    end

    def item(context, key, value, style)
      {
        label: I18n.t("accounts.balance_reconciliation.#{context}.#{key}.label"),
        value: value,
        tooltip: I18n.t("accounts.balance_reconciliation.#{context}.#{key}.tooltip"),
        style: style
      }
    end

    def net_cash_flow
      balance.cash_inflows_money - balance.cash_outflows_money
    end

    def net_non_cash_flow
      balance.non_cash_inflows_money - balance.non_cash_outflows_money
    end

    def net_total_flow
      net_cash_flow + net_non_cash_flow + balance.net_market_flows_money
    end

    def total_adjustments
      balance.cash_adjustments_money + balance.non_cash_adjustments_money
    end

    def has_adjustments?
      balance.cash_adjustments != 0 || balance.non_cash_adjustments != 0
    end

    def end_balance_before_adjustments
      balance.end_balance_money - total_adjustments
    end
end
