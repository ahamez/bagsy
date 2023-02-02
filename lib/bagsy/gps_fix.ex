defmodule Bagsy.GpsFix do
  # https://docs.ros.org/en/hydro/api/gps_common/html/msg/GPSFix.html

  alias Bagsy.{Cdr, GpsStatus, Header}

  defstruct ~w(
    header
    gps_status
    latitude
    longitude
    altitude
    track
    speed
    climb
    pitch
    roll
    dip
    time
    gdop
    pdop
    hdop
    vdop
    tdop
    err
    err_horz
    err_vert
    err_track
    err_speed
    err_climb
    err_time
    err_pitch
    err_roll
    err_dip
    position_covariance
    position_covariance_type
    )a

  def parse(bytes, offset \\ 0) do
    {header, bytes, offset} = Header.parse(bytes, offset)
    {gps_status, bytes, offset} = GpsStatus.parse(bytes, offset)
    {latitude, bytes, offset} = Cdr.float64(bytes, offset)
    {longitude, bytes, offset} = Cdr.float64(bytes, offset)
    {altitude, bytes, offset} = Cdr.float64(bytes, offset)
    {track, bytes, offset} = Cdr.float64(bytes, offset)
    {speed, bytes, offset} = Cdr.float64(bytes, offset)
    {climb, bytes, offset} = Cdr.float64(bytes, offset)
    {pitch, bytes, offset} = Cdr.float64(bytes, offset)
    {roll, bytes, offset} = Cdr.float64(bytes, offset)
    {dip, bytes, offset} = Cdr.float64(bytes, offset)
    {time, bytes, offset} = Cdr.float64(bytes, offset)
    {gdop, bytes, offset} = Cdr.float64(bytes, offset)
    {pdop, bytes, offset} = Cdr.float64(bytes, offset)
    {hdop, bytes, offset} = Cdr.float64(bytes, offset)
    {vdop, bytes, offset} = Cdr.float64(bytes, offset)
    {tdop, bytes, offset} = Cdr.float64(bytes, offset)
    {err, bytes, offset} = Cdr.float64(bytes, offset)
    {err_horz, bytes, offset} = Cdr.float64(bytes, offset)
    {err_vert, bytes, offset} = Cdr.float64(bytes, offset)
    {err_track, bytes, offset} = Cdr.float64(bytes, offset)
    {err_speed, bytes, offset} = Cdr.float64(bytes, offset)
    {err_climb, bytes, offset} = Cdr.float64(bytes, offset)
    {err_time, bytes, offset} = Cdr.float64(bytes, offset)
    {err_pitch, bytes, offset} = Cdr.float64(bytes, offset)
    {err_roll, bytes, offset} = Cdr.float64(bytes, offset)
    {err_dip, bytes, offset} = Cdr.float64(bytes, offset)
    {position_covariance, bytes, offset} = Cdr.tensor_float64_fixed_size(bytes, offset, 9)
    {position_covariance_type, bytes, offset} = Cdr.uint8(bytes, offset)

    {
      %__MODULE__{
        header: header,
        gps_status: gps_status,
        latitude: latitude,
        longitude: longitude,
        altitude: altitude,
        track: track,
        speed: speed,
        climb: climb,
        pitch: pitch,
        roll: roll,
        dip: dip,
        time: time,
        gdop: gdop,
        pdop: pdop,
        hdop: hdop,
        vdop: vdop,
        tdop: tdop,
        err: err,
        err_horz: err_horz,
        err_vert: err_vert,
        err_track: err_track,
        err_speed: err_speed,
        err_climb: err_climb,
        err_time: err_time,
        err_pitch: err_pitch,
        err_roll: err_roll,
        err_dip: err_dip,
        position_covariance: position_covariance,
        position_covariance_type: position_covariance_type
      },
      bytes,
      offset
    }
  end
end
