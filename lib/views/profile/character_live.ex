defmodule Bonfire.UI.Me.CharacterLive do
  use Bonfire.UI.Common.Web, :surface_live_view
  alias Bonfire.Me.Integration
  import Untangle

  # alias Bonfire.Me.Fake
  alias Bonfire.UI.Me.LivePlugs

  def mount(params, session, socket) do
    live_plug(params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      # LivePlugs.LoadCurrentUserCircles,
      Bonfire.UI.Common.LivePlugs.StaticChanged,
      Bonfire.UI.Common.LivePlugs.Csrf,
      Bonfire.UI.Common.LivePlugs.Locale,
      &mounted/3
    ])
  end

  defp mounted(params, _session, socket) do
    # info(params)

    current_user = current_user(socket)
    current_username = e(current_user, :character, :username, nil)

    user_etc =
      case Map.get(params, "id") do
        nil ->
          current_user

        username when username == current_username ->
          current_user

        "@" <> username ->
          "/@" <> username

        "+" <> username ->
          "/+" <> username

        username ->
          # TODO: really need to query here?
          Bonfire.UI.Me.ProfileLive.get(username)
      end
      |> debug("user_etc")

    if user_etc do
      if is_binary(user_etc) do
        # redir to profile path
        {:ok,
         redirect_to(
           socket,
           user_etc
         )}
      else
        # show profile locally
        if current_user || Integration.is_local?(user_etc) do
          {:ok,
           redirect_to(
             socket,
             path(user_etc)
           )}
        else
          # redir to remote profile
          {:ok,
           redirect(socket,
             external: canonical_url(user_etc)
           )}
        end
      end
    else
      {:ok,
       socket
       |> assign_flash(:error, l("Not found"))
       |> redirect_to(path(:error))}
    end
  end

  def render(assigns) do
    ~F"""
    Error - this URL should have redirected you.
    """
  end
end
