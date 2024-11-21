module ShapeHelpers
  def self.determinant(xa, ya, xb, yb, xc, yc)
    xab = xb - xa
    yab = yb - ya
    xac = xc - xa
    yac = yc - ya
    # cross product
    return yab * xac - xab * yac
  end

  def self.triangle_area(x1,y1,x2,y2,x3,y3)
    a2 = (x2 - x1)**2 + (y2 - y1)**2
    b2 = (x3 - x2)**2 + (y3 - y2)**2
    c2 = (x1 - x3)**2 + (y1 - y3)**2
    a = Math.sqrt(a2)
    b = Math.sqrt(b2)

    gamma = Math.acos((a2 + b2 - c2) / (2 * a * b))
    return 0.5 * a * b * Math.sin(gamma)
  end
    
  def self.get_triangle_bounds(x1,y1,x2,y2,x3,y3)
    bounds = [[[x1,x2,x3].min,[y1,y2,y3].min],[[x1,x2,x3].max,[y1,y2,y3].max]]
    return Rect.new(bounds[0][0], bounds[0][1], bounds[1][0] - bounds[0][0], bounds[1][1] - bounds[0][1])
  end
  
  def self.point_in_triangle(x1,y1,x2,y2,x3,y3,px,py)
    return false if ShapeHelpers.determinant(x1,y1,x2,y2,px,py) < 0
    return false if ShapeHelpers.determinant(x2,y2,x3,y3,px,py) < 0
    return false if ShapeHelpers.determinant(x3,y3,x1,y1,px,py) < 0
    return true
  end
  
  def self.get_convex_shape_bounds(vertices)
    bounds = [vertices[0][0], vertices[0][1], vertices[0][0], vertices[0][1]]
    vertices.each do |v|
      bounds[0] = v[0] if v[0] < bounds[0]
      bounds[1] = v[1] if v[1] < bounds[1]
      bounds[2] = v[0] if v[0] > bounds[2]
      bounds[3] = v[1] if v[1] > bounds[3]
    end
    return Rect.new(bounds[0], bounds[1], bounds[2] - bounds[0], bounds[3] - bounds[1])
  end

  
  def self.point_in_convex_shape(vertices,x,y)
    vertices.length.times do |i1|
      i2 = (i1 + 1) % vertices.length
      return false if ShapeHelpers.determinant(
        vertices[i1][0],vertices[i1][1],
        vertices[i2][0],vertices[i2][1], x,y) >= 0
    end
    return true
  end
end