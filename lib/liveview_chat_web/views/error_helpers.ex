defmodule LiveviewChatWeb.ErrorHelpers do
  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:span, translate_error(error), class: "help-block")
    end)
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, the `%{count}` interpolation is
    # a special case we need to handle.
    if count = opts[:count] do
      Gettext.dngettext(LiveviewChatWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(LiveviewChatWeb.Gettext, "errors", msg, opts)
    end
  end
end
