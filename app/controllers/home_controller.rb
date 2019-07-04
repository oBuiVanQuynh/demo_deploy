class HomeController < ActionController::Base
  def index
    ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
    @ip_v4 = ip.ip_address
  end
end
