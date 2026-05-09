defmodule SymphonyElixir.Product.Bootstrap.Task do
  @moduledoc """
  A Product Symphony task parsed from a bootstrap brief.
  """

  @enforce_keys [:title, :mode]
  defstruct [
    :title,
    :mode,
    :deliverable,
    :acceptance,
    :body,
    priority: nil
  ]

  @type t :: %__MODULE__{
          title: String.t(),
          mode: String.t(),
          deliverable: String.t() | nil,
          acceptance: String.t() | nil,
          body: String.t() | nil,
          priority: integer() | nil
        }
end

