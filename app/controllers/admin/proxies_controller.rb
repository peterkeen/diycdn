module Admin
  class ProxiesController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Proxy.
    #     page(params[:page]).
    #     per(10)
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Proxy.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information

    def force_setup
      Proxy.find_each do |proxy|
        proxy.update_column(:needs_setup, true)
      end

      redirect_to admin_proxies_path, notice: "Forced setup"
    end
  end
end
