defmodule Bonfire.UI.Me.UsersDirectoryLive do
  use Bonfire.UI.Common.Web, :surface_live_view
  alias Bonfire.UI.Me.LivePlugs
  import Bonfire.UI.Me.Integration

  def mount(params, session, socket) do
    live_plug(params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      # LivePlugs.AccountRequired,
      # LivePlugs.LoadCurrentUserCircles,
      # LivePlugs.LoadCurrentAccountUsers,
      Bonfire.UI.Common.LivePlugs.StaticChanged,
      Bonfire.UI.Common.LivePlugs.Csrf,
      Bonfire.UI.Common.LivePlugs.Locale,
      &mounted/3
    ])
  end

  defp mounted(_params, _session, socket) do
    current_user = current_user(socket)

    show_to =
      Bonfire.Me.Settings.get(
        [Bonfire.UI.Me.UsersDirectoryLive, :show_to],
        :users
      )

    if show_to || is_admin?(current_user) do
      if show_to == :guests or current_user(socket) || current_account(socket) do
        users = Bonfire.Me.Users.list(current_user)

        count = Bonfire.Me.Users.maybe_count()

        {:ok,
         assign(
           socket,
           page_title:
             if(count,
               do: l("Users directory (%{total})", total: count),
               else: l("Users directory")
             ),
           page: "users",
           search_placeholder: "Search users",
           users: users
         )}
      else
        error(l("You need to log in before browsing the user directory"))
      end
    else
      error(l("The user directory is disabled on this instance"))
    end
  end

  def handle_params(params, uri, socket),
    do:
      Bonfire.UI.Common.LiveHandlers.handle_params(
        params,
        uri,
        socket,
        __MODULE__
      )

  def handle_info(info, socket),
    do: Bonfire.UI.Common.LiveHandlers.handle_info(info, socket, __MODULE__)

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
