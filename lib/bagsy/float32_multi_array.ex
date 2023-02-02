defmodule Bagsy.Float32MultiArray do
  # https://docs.ros2.org/galactic/api/std_msgs/msg/Float32MultiArray.html

  alias Bagsy.Cdr

  defstruct ~w(layout data)a

  def parse(bytes, offset \\ 0) do
    {layout, bytes, offset} = Bagsy.MultiArrayLayout.parse(bytes, offset)
    {data, bytes, offset} = Cdr.tensor_float32(bytes, offset)

    {
      %__MODULE__{
        layout: layout,
        data: data
      },
      bytes,
      offset
    }
  end
end
