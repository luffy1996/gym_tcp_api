_ = """
  @file gym_tcp_api.ex
  @author Marcus Edel

  GymTcpApi handler.
"""

defmodule GymTcpApi do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    poolboy_config = [
      {:name, {:local, pool_name()}},
      {:worker_module, GymTcpApi.Worker},
      {:size, Application.get_env(:gym_tcp_api, :worker)},
      {:max_overflow, 0},
      {:strategy, :fifo}
    ]

    children = [
      :poolboy.child_spec(pool_name(), poolboy_config, []),
      supervisor(Task.Supervisor, [[name: GymTcpApi.TaskSupervisor]]),
      worker(Task, [GymTcpApi.Server, :accept,
          [Application.get_env(:gym_tcp_api, :port)]])
    ]

    options = [
      strategy: :one_for_one,
      name: GymTcpApi.Supervisor
    ]

    Supervisor.start_link(children, options)
  end

  def pool_name() do
    :gym_pool
  end
end
