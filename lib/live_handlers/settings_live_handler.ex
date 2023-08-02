defmodule Bonfire.Me.Settings.LiveHandler do
  use Bonfire.UI.Common.Web, :live_handler
  # import Bonfire.Boundaries.Integration

  def handle_event("prepare_archive", _params, socket) do
    with :ok <- prepare_archive_async(socket) do
      {:noreply,
       socket
       |> assign_flash(
         :info,
         l(
           "Preparing your archive... You will notified here when it is ready to download (you can continue browsing Bonfire but please keep it open)."
         )
       )}
    end
  end

  def prepare_archive_async(%{assigns: %{__context__: context}} = _socket) do
    Bonfire.UI.Me.ExportController.zip_archive(context, current_user_required!(context))
  end

  def handle_event("put", %{"keys" => keys, "values" => value} = params, socket) do
    with {:ok, settings} <-
           keys
           |> String.split(":")
           #  |> debug()
           |> Bonfire.Me.Settings.put(value, scope: params["scope"], socket: socket) do
      # debug(settings, "done")
      {:noreply,
       socket
       |> maybe_assign_context(settings)
       |> assign_flash(:info, l("Settings saved :-)"))}
    end
  end

  def handle_event("set", attrs, socket) when is_map(attrs) do
    with {:ok, settings} <-
           Map.drop(attrs, ["_target"]) |> Bonfire.Me.Settings.set(socket: socket) do
      # debug(settings, "done")
      {:noreply,
       socket
       |> maybe_assign_context(settings)
       |> assign_flash(:info, l("Settings saved :-)"))}
    end
  end

  def handle_event("save", attrs, socket) when is_map(attrs) do
    with {:ok, settings} <-
           Map.drop(attrs, ["_target"]) |> Bonfire.Me.Settings.set(socket: socket) do
      {
        :noreply,
        socket
        |> maybe_assign_context(settings)
        |> assign_flash(:info, l("Settings saved :-)"))
        #  |> redirect_to("/")
      }
    end
  end

  def handle_event("put_theme", %{"keys" => keys, "values" => value} = params, socket) do
    with {:ok, _settings} <-
           keys
           |> String.split(":")
           #  |> debug()
           |> Bonfire.Me.Settings.put(value, scope: params["scope"], socket: socket) do
      # debug(settings, "done")
      {:noreply,
       socket
       #  |> maybe_assign_context(settings)
       |> assign_flash(:info, l("Theme changed and loaded :-)"))
       |> redirect(to: current_url(socket) || "/")}
    end
  end

  def handle_event("extension:disable", %{"extension" => extension} = attrs, socket) do
    extension_toggle(extension, true, attrs, socket)
  end

  def handle_event("extension:enable", %{"extension" => extension} = attrs, socket) do
    extension_toggle(extension, nil, attrs, socket)
  end

  # LiveHandler
  def handle_event("set_locale", %{"locale" => locale}, socket) do
    Bonfire.Common.Localise.put_locale(locale)
    |> debug("set current UI locale")

    # then save to settings
    %{"Bonfire.Common.Localise.Cldr" => %{"default_locale" => locale}}
    |> handle_event("set", ..., socket)
  end

  def handle_event("delete_user", %{"password" => password}, socket) do
    current_user_auth!(socket, password)

    after_delete(
      Bonfire.Me.DeleteWorker.do_delete(current_user_id(socket)),
      "/switch-user",
      socket
    )
  end

  def handle_event("delete_account", %{"password" => password}, socket) do
    current_account_auth!(socket, password)
    after_delete(Bonfire.Me.Accounts.queue_delete(current_account(socket)), "/logout", socket)
  end

  defp after_delete(result, redirect_after, socket) do
    with {:ok, _} <- result do
      Bonfire.UI.Common.OpenModalLive.close()

      {:noreply,
       socket
       |> assign_flash(
         :info,
         l(
           "Queued for deletion. Should be done in a few minutes... So long, and thanks for all the fish!"
         )
       )
       |> redirect_to(
         redirect_after,
         fallback: current_url(socket)
       )}
    end
  end

  defp maybe_assign_context(socket, %{assign_context: assigns}) do
    debug(assigns, "assign updated data with settings")

    socket
    |> assign_global(assigns)
  end

  defp maybe_assign_context(socket, %{id: "3SERSFR0MY0VR10CA11NSTANCE", data: settings}) do
    debug(settings, "assign updated instance settings")

    socket
    |> assign_global(instance_settings: settings)
  end

  defp maybe_assign_context(socket, ret) do
    debug(ret, "cannot assign updated data with settings")
    socket
  end

  defp extension_toggle(extension, disabled?, attrs, socket) do
    scope =
      maybe_to_atom(e(attrs, "scope", nil))
      |> debug("scope")

    with {:ok, settings} <-
           Bonfire.Me.Settings.put([extension, :disabled], disabled?,
             scope: scope,
             socket: socket
           ) do
      # generate an updated reverse router based on extensions that are enabled/disabled
      if scope == :instance, do: Bonfire.Common.Extend.generate_reverse_router!()

      {
        :noreply,
        socket
        |> maybe_assign_context(settings)
        |> assign_flash(:info, "Extension toggled :-)")
        #  |> redirect_to(current_url(socket))
      }
    end
  end

  def set_image_setting(:icon, scope, uploaded_media, settings_key, socket) do
    url = Bonfire.Files.IconUploader.remote_url(uploaded_media)

    with {:ok, settings} <-
           Bonfire.Me.Settings.put(
             settings_key,
             url,
             scope: scope,
             socket: socket
           ) do
      {
        :noreply,
        socket
        |> assign_flash(:info, l("Icon changed!"))
        |> assign(src: url)
        |> maybe_assign_context(settings)
        #  |> redirect_to(~p"/about")
      }
    end
  end

  def set_image_setting(:banner, scope, uploaded_media, settings_key, socket) do
    url = Bonfire.Files.BannerUploader.remote_url(uploaded_media)

    with {:ok, settings} <-
           Bonfire.Me.Settings.put(
             settings_key,
             url,
             scope: scope,
             socket: socket
           ) do
      {
        :noreply,
        socket
        |> assign_flash(:info, l("Image changed!"))
        |> assign(src: url)
        |> maybe_assign_context(settings)
        #  |> redirect_to(~p"/about")
      }
    end
  end
end
