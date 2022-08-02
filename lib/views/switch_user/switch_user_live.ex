defmodule Bonfire.UI.Me.SwitchUserLive do
  use Bonfire.UI.Common.Web, :surface_live_view
  alias Bonfire.UI.Me.LivePlugs

  def mount(params, session, socket) do
    live_plug params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      # LivePlugs.LoadCurrentUser,
      LivePlugs.AccountRequired,
      LivePlugs.LoadCurrentAccountUsers,
      Bonfire.UI.Common.LivePlugs.StaticChanged,
      Bonfire.UI.Common.LivePlugs.Csrf,
      Bonfire.UI.Common.LivePlugs.Locale,
      &mounted/3,
    ]
  end

  defp mounted(_, _, socket), do: {:ok,
    assign(
      socket, 
      current_user: nil, 
      sidebar_widgets: [
        users: [
          main: [
            {Bonfire.UI.Common.WidgetInstanceInfoLive, []},
          ],
          secondary: [
            {Bonfire.UI.Social.WidgetTagsLive, []}
          ]
        ],
        guests: [
          main: [
            {Bonfire.UI.Common.WidgetInstanceInfoLive, []},
          ],
          secondary: [
            {Bonfire.UI.Social.WidgetTagsLive, []}
          ]
        ]
      ],
      go: Map.get(socket.assigns, :go, ""), 
      page_title: l "Switch user profile"),
  }

end
