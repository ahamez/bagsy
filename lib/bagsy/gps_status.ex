defmodule Bagsy.GpsStatus do
  # http://docs.ros.org/en/hydro/api/gps_common/html/msg/GPSStatus.html

  alias Bagsy.{Cdr, Header}

  defstruct [
    :header,
    :satellites_used,
    :satellites_used_prn,
    :satellites_visible,
    :satellites_visible_prn,
    :satellites_visible_z,
    :satellites_visible_azimuth,
    :satellites_visible_snr,
    :status,
    :motion_source,
    :orientation_source,
    :position_source
  ]

  def parse(bytes, offset) do
    {header, bytes, offset} = Header.parse(bytes, offset)

    {satellites_used, bytes, offset} = Cdr.uint16(bytes, offset)
    {satellites_used_prn, bytes, offset} = Cdr.array_uint32(bytes, offset)
    {satellites_visible, bytes, offset} = Cdr.uint16(bytes, offset)
    {satellites_visible_prn, bytes, offset} = Cdr.array_uint32(bytes, offset)
    {satellites_visible_z, bytes, offset} = Cdr.array_uint32(bytes, offset)
    {satellites_visible_azimuth, bytes, offset} = Cdr.array_uint32(bytes, offset)
    {satellites_visible_snr, bytes, offset} = Cdr.array_uint32(bytes, offset)
    {status, bytes, offset} = Cdr.int16(bytes, offset)
    {motion_source, bytes, offset} = Cdr.uint16(bytes, offset)
    {orientation_source, bytes, offset} = Cdr.uint16(bytes, offset)
    {position_source, bytes, offset} = Cdr.uint16(bytes, offset)

    {
      %__MODULE__{
        header: header,
        satellites_used: satellites_used,
        satellites_used_prn: satellites_used_prn,
        satellites_visible: satellites_visible,
        satellites_visible_prn: satellites_visible_prn,
        satellites_visible_z: satellites_visible_z,
        satellites_visible_azimuth: satellites_visible_azimuth,
        satellites_visible_snr: satellites_visible_snr,
        status: status,
        motion_source: motion_source,
        orientation_source: orientation_source,
        position_source: position_source
      },
      bytes,
      offset
    }
  end
end
