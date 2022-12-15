defmodule RewardApp.Tasks.UpdateDatabase do
  use GenServer
  alias RewardApp.Accounts

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    IO.puts "Updating database..."
    # Accounts.set_points_monthly()
    # schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    :timer.send_interval(3600 * 1000, :work)
    # Process.send_after(self(), :work, 2 * 60 * 60 * 1000) # In 2 hours
  end

end


# defmodule MyGenServer do
#   use GenServer

#   def start_link(opts) do
#     GenServer.start_link(__MODULE__, opts, name: __MODULE__)
#   end

#   def init(opts) do
#     schedule_work()
#     {:ok, opts}
#   end

#   def schedule_work() do
#     # Get the current time
#     current_time = :calendar.local_time()

#     # Calculate the time at midnight on the first day of the next month
#     next_month = :calendar.add_months(current_time, 1)
#     first_day_of_next_month = {{next_month.year, next_month.month, 1}, {0, 0, 0}}

#     # Calculate the time delay until midnight on the first day of the next month
#     time_delay = :calendar.diff(first_day_of_next_month, current_time)

#     # Schedule a message to be sent to the GenServer at midnight on the first day of the next month
#     :timer.send_after(time_delay, :do_work)
#   end

#   def handle_info(:do_work, state) do
#     # Perform the work here
#     IO.puts("Doing work!")

#     # Reschedule the work for the first day of the next month
#     schedule_work()

#     {:noreply, state}
#   end
# end
