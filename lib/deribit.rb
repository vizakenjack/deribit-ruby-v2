require "deribit/version"
require "deribit/error"
require "deribit/api"
require "deribit/ws"
require "deribit/ws/base_handler"
require "deribit/ws/handler"

module Deribit
  API_VERSION = "v2"
  SERVER_URL = "https://www.deribit.com/api/#{API_VERSION}/"
  TEST_URL = "https://test.deribit.com/api/#{API_VERSION}/"
  WS_SERVER_URL = "wss://www.deribit.com/ws/api/#{API_VERSION}/"
  WS_TEST_URL = "wss://test.deribit.com/ws/api/#{API_VERSION}/"

  API_METHODS = {
    "private/add_to_address_book" => %i(currency type address name tfa),
    "private/buy" => %i(instrument_name amount type label price time_in_force max_show post_only reduce_only stop_price trigger advanced),
    "private/cancel" => %i(order_id),
    "private/cancel_all" => [],
    "private/cancel_all_by_currency" => %i(currency kind type),
    "private/cancel_all_by_instrument" => %i(instrument_name type),
    "private/cancel_transfer_by_id" => %i(currency id tfa),
    "private/cancel_withdrawal" => %i(currency id),
    "private/change_subaccount_name" => %i(sid name),
    "private/close_position" => %i(instrument_name type price),
    "private/create_deposit_address" => %i(currency),
    "private/create_subaccount" => [],
    "private/disable_tfa_for_subaccount" => %i(sid),
    "private/edit" => %i(order_id amount price post_only advanced stop_price),
    "private/get_account_summary" => %i(currency extended),
    "private/get_address_book" => %i(currency type),
    "private/get_current_deposit_address" => %i(currency),
    "private/get_deposits" => %i(currency count offset),
    "private/get_email_language" => [],
    "private/get_margins" => %i(instrument_name amount price),
    "private/get_new_announcements" => [],
    "private/get_open_orders_by_currency" => %i(currency kind type),
    "private/get_open_orders_by_instrument" => %i(instrument_name type),
    "private/get_order_history_by_currency" => %i(currency kind count offset include_old include_unfilled),
    "private/get_order_history_by_instrument" => %i(instrument_name count offset include_old include_unfilled),
    "private/get_order_margin_by_ids" => %i(ids),
    "private/get_order_state" => %i(order_id),
    "private/get_position" => %i(instrument_name),
    "private/get_positions" => %i(currency kind),
    "private/get_settlement_history_by_currency" => %i(currency type count),
    "private/get_settlement_history_by_instrument" => %i(instrument_name type count),
    "private/get_subaccounts" => %i(with_portfolio),
    "private/get_transfers" => %i(currency count offset),
    "private/get_user_trades_by_currency" => %i(currency kind start_id end_id count include_old sorting),
    "private/get_user_trades_by_currency_and_time" => %i(currency kind start_timestamp end_timestamp count include_old sorting),
    "private/get_user_trades_by_instrument" => %i(instrument_name start_seq end_seq count include_old sorting),
    "private/get_user_trades_by_instrument_and_time" => %i(instrument_name start_timestamp end_timestamp count include_old sorting),
    "private/get_user_trades_by_order" => %i(order_id sorting),
    "private/get_withdrawals" => %i(currency count offset),
    "private/getopenorders" => %i(instrument orderId type),
    "private/orderhistory" => %i(count instrument offset),
    "private/orderstate" => %i(orderId),
    "private/positions" => %i(currency),
    "private/remove_from_address_book" => %i(currency type address tfa),
    "private/sell" => %i(instrument_name amount type label price time_in_force max_show post_only reduce_only stop_price trigger advanced),
    "private/set_announcement_as_read" => %i(announcement_id),
    "private/set_email_for_subaccount" => %i(sid email),
    "private/set_email_language" => %i(language),
    "private/set_password_for_subaccount" => %i(sid password),
    "private/submit_transfer_to_subaccount" => %i(currency amount destination),
    "private/submit_transfer_to_user" => %i(currency amount destination tfa),
    "private/toggle_deposit_address_creation" => %i(currency state),
    "private/toggle_notifications_from_subaccount" => %i(sid state),
    "private/toggle_subaccount_login" => %i(sid state),
    "private/tradehistory" => %i(sort instrument count startId endId startSeq endSeq startTimestamp endTimestamp since direction),
    "private/withdraw" => %i(currency address amount priority tfa),
    "public/auth" => %i(grant_type username password client_id client_secret refresh_token timestamp signature nonce state scope),
    "public/get_announcements" => [],
    "public/get_book_summary_by_currency" => %i(currency kind),
    "public/get_book_summary_by_instrument" => %i(instrument_name),
    "public/get_contract_size" => %i(instrument_name),
    "public/get_currencies" => [],
    "public/get_footer" => [],
    "public/get_funding_chart_data" => %i(instrument_name length),
    "public/get_historical_volatility" => %i(currency),
    "public/get_index" => %i(currency),
    "public/get_instruments" => %i(currency kind expired),
    "public/get_last_settlements_by_currency" => %i(currency type count continuation search_start_timestamp),
    "public/get_last_settlements_by_instrument" => %i(instrument_name type count continuation search_start_timestamp),
    "public/get_last_trades_by_currency" => %i(currency kind start_seq end_seq count include_old sorting),
    "public/get_last_trades_by_currency_and_time" => %i(currency kind start_timestamp end_timestamp count include_old sorting),
    "public/get_last_trades_by_instrument" => %i(instrument_name start_seq end_seq count include_old sorting),
    "public/get_last_trades_by_instrument_and_time" => %i(instrument_name start_timestamp end_timestamp count include_old sorting),
    "public/get_option_mark_prices" => %i(currency),
    "public/get_order_book" => %i(instrument_name depth),
    "public/get_time" => [],
    "public/get_trade_volumes" => [],
    "public/getlasttrades" => %i(sort instrument count startId endId startSeq endSeq startTimestamp endTimestamp since direction),
    "public/getorderbook" => %i(instrument depth),
    "public/ping" => [],
    "public/test" => %i(expected_result),
    "public/ticker" => %i(instrument_name),
    "public/validate_field" => %i(field value value2),
    # === WEBSOCKETS === #
    "private/enable_cancel_on_disconnect" => [],
    "private/disable_cancel_on_disconnect" => [],
    "private/logout" => [],
    "public/hello" => %i(client_name client_version),
    "public/set_heartbeat" => %i(interval),
    "public/disable_heartbeat" => [],
    "public/subscribe" => %i(channels),
    "public/unsubscribe" => %i(channels),
  }

  def self.find_method(method_name, params = {})
    if found = API_METHODS.find { |e| e[0].end_with?(method_name.to_s) }
      { method: method_name, path: found[0], params: found[1] }.tap { |data| check_params(data, params) }
    else
      raise Error.new(message: "Deribit API: invalid method #{method_name}")
    end
  end

  def self.check_params(data, params)
    return true unless params.any?

    params.keys.each do |key|
      puts "DERIBIT-RUBY WARNING: param `#{key}` is not allowed " if key && !data[:params].include?(key)
    end
  end
end
