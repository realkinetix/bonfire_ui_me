defmodule Bonfire.UI.Me.SettingsViewsLive.InstanceMembersLive do
  use Bonfire.UI.Common.Web, :stateful_component

  prop selected_tab, :string
  prop ghosted_instance_wide?, :boolean, default: nil
  prop silenced_instance_wide?, :boolean, default: nil

  def preload([%{skip_preload: true}] = list_of_assigns) do
    list_of_assigns
  end

  def preload(list_of_assigns) do
    users = Bonfire.Me.Users.list_all()

    users = Enum.map(users, fn user ->
      user
      |> Map.put(:ghosted_instance_wide?, Bonfire.Boundaries.Blocks.is_blocked?(id(user), :ghost, :instance_wide))
      |> Map.put(:silenced_instance_wide?, Bonfire.Boundaries.Blocks.is_blocked?(id(user), :silence, :instance_wide))
    end)

    Enum.map(list_of_assigns, fn assigns ->
      Map.put(assigns, :users, users)
    end)

  end

  # def update(assigns, socket) do
    # IO.inspect(assigns, label: "assigns")
    # current_user = current_user(assigns)
    # tab = e(assigns, :selected_tab, nil)

    # users = Bonfire.Me.Users.list(current_user)
    # count = Bonfire.Me.Users.maybe_count()

  #   {:ok,
  #    assign(
  #      socket,
  #      selected_tab: tab,
  #      ghosted_instance_wide?: nil,
  #      silenced_instance_wide?: nil,
  #      current_user: current_user,
  #      page_title:
  #        if(count,
  #          do: l("Users directory (%{total})", total: count),
  #          else: l("Users directory")
  #        ),
  #      page: "users",
  #      users: users
  #    )}
  # end

  def handle_event(
        action,
        attrs,
        socket
      ),
      do:
        Bonfire.UI.Common.LiveHandlers.handle_event(
          action,
          attrs,
          socket,
          __MODULE__
          # &do_handle_event/3
        )
end
