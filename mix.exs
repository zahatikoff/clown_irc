defmodule ClownIRC.MixProject do
  use Mix.Project

  def project do
    [
      app: :clown_irc,
      version: "0.0.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~>1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~>0.34", only: :dev, runtime: false}
    ]
  end
end
