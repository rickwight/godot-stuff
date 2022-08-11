# Monotone Cubic Interpolation, ripped from wikipedia and adapted to GDScript

class_name MonoCubicLerp

var points = null
var dxs = []
var dys = []
var ms = []
var c1s = []
var c2s = []
var c3s = []

# points must be sorted by x-values
func _init(p_points:Array):
	points = p_points
	assert(points.size() > 1)
	
	# Calculate differences and slopes
	for i in points.size() - 1:
		var p = points[i]
		var pN = points[i+1]
		assert(pN.x > p.x)
		var dx = pN.x - p.x
		var dy = pN.y - p.y
		dxs.append(dx)
		dys.append(dy)
		ms.append(dy/dx)
	
	# Calculate degree-1 coefficients
	c1s.append(ms[0])
	for i in dxs.size() - 1:
		var m = ms[i]
		var mN = ms[i+1]
		if m * mN <= 0:
			c1s.append(0)
		else:
			var dx = dxs[i]
			var dxN = dxs[i+1]
			var common = dx + dxN;
			c1s.append(3.0 * common / ((common + dxN) / m + (common + dx) / mN))
	c1s.append(ms[ms.size()-1]);
	
	# Calculate degree-2 and degree-3 coefficients
	for i in c1s.size() - 1:
		var c1 = c1s[i]
		var m = ms[i]
		var invDx = 1.0/dxs[i]
		var common = c1 + c1s[i+1] - m - m
		c2s.append((m - c1 - common) * invDx)
		c3s.append(common * invDx * invDx)

func f(x:float) -> float:
	# The rightmost point in the dataset should give an exact result
	var last = points.size() - 1;
	if x == points[last].x:
		return points[last].y
	
	# Search for the interval x is in, returning the corresponding y if x is one of the original xs
	var lo = 0
	var mid = 0
	var hi = c3s.size() - 1
	while lo <= hi:
		mid = floor(0.5*(lo + hi))
		var xHere = points[mid].x
		if xHere < x:
			lo = mid + 1
		elif xHere > x:
			hi = mid - 1
		else:
			return points[mid].y
	var i = max(0, hi)
	
	# Interpolate
	var diff = x - points[i].x
	var diffSq = pow(diff, 2)
	return points[i].y + (c1s[i] * diff) + (c2s[i] * diffSq) + (c3s[i] * diff * diffSq)
