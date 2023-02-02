defmodule Bagsy.Header do
  # http://docs.ros.org/en/hydro/api/std_msgs/html/msg/Header.html

  alias Bagsy.Cdr

  defstruct [:ts_sec, :ts_nsec, :frame_id]

  def parse(bytes, offset) do
    {ts_sec, bytes, offset} = Cdr.uint32(bytes, offset)
    {ts_nsec, bytes, offset} = Cdr.uint32(bytes, offset)
    {frame_id, bytes, offset} = Cdr.string(bytes, offset)

    {
      %__MODULE__{
        ts_sec: ts_sec,
        ts_nsec: ts_nsec,
        frame_id: frame_id
      },
      bytes,
      offset
    }
  end
end
