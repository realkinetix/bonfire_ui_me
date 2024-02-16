defmodule Bonfire.UI.Me.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use MyApp.Web.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest

      import Bonfire.UI.Common.Testing.Helpers

      import Phoenix.LiveViewTest
      import Surface.LiveViewTest

      import PhoenixTest

      # import Bonfire.UI.Me.ConnCase
      import Bonfire.UI.Me.Test.ConnHelpers
      import Bonfire.UI.Me.Test.FakeHelpers
      import Bonfire.Common.Simulation
      import Bonfire.Me.Fake.Helpers
      import Bonfire.UI.Me.Integration

      import Untangle
      use Arrows
      # alias Bonfire.UI.Me.Web.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint Application.compile_env!(:bonfire, :endpoint_module)
      # |> IO.inspect()
    end
  end

  setup tags do
    # import Bonfire.UI.Me.Integration

    Bonfire.Common.Test.Interactive.setup_test_repo(tags)

    {:ok, []}
  end
end
