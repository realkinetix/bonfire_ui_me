defmodule Bonfire.UI.Me.SettingsViewsLive.InstancePagesLive do
  use Bonfire.UI.Common.Web, :stateful_component

  prop selected_tab, :string

  def update(assigns, socket) do
    current_user = current_user(assigns)
    tab = e(assigns, :selected_tab, nil)

    {:ok,
     assign(
       socket,
       selected_tab: tab,
       current_user: current_user,
       pages: Bonfire.Pages.list_paginated()
     )}
  end
end
