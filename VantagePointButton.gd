extends Button

var vantage_point: VantagePoint

func set_vantage_point(vp: VantagePoint):
	vantage_point = vp
	text = vantage_point.tool_name
