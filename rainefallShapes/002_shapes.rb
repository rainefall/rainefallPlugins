class Bitmap
  COLOR_ALPHA = Color.new(0,0,0,0)
  @@shape_buffer = Bitmap.new(Bitmap.max_size, Bitmap.max_size)
  
  def draw_circle(cx, cy, radius, color)
    d = radius * 2
    @@shape_buffer.fill_rect(Rect.new(0, 0, d, d), color)
    cutout_circle(cx, cy, radius)
  end
  
  def draw_ellipse(cx, cy, rx, ry, color)
    @@shape_buffer.fill_rect(Rect.new(0, 0, rx*2, ry*2), color)
    cutout_ellipse(cx, cy, rx, ry)
  end
  
  def draw_triangle(x1,y1,x2,y2,x3,y3,color)
    bounds = ShapeHelpers.get_triangle_bounds(x1,y1,x2,y2,x3,y3)
    if ShapeHelpers.triangle_area(x1,y1,x2,y2,x3,y3) > (bounds.width * bounds.height / 2)
      @@shape_buffer.fill_rect(bounds, color)
      cutout_triangle(x1,y1,x2,y2,x3,y3,bounds)
    else
      bounds.height.times do |y|
        yy = bounds.y + y
        bounds.width.times do |x|
          xx = bounds.x + x
          @@shape_buffer.set_pixel(xx, yy, color) if ShapeHelpers.point_in_convex_shape([[x1,y1],[x2,y2],[x3,y3]],xx,yy)
        end
      end
    end
  end
  
  def draw_convex_shape(vertices,color)
    bounds = ShapeHelpers.get_convex_shape_bounds(vertices)
    @@shape_buffer.fill_rect(bounds, color)
    cutout_convex_shape(vertices,bounds)
  end
  
  def draw_textured_circle(cx, cy, radius, bmp, texture_rect = nil)
    texture_rect ||= bmp.rect
    d = radius * 2
    @@shape_buffer.stretch_blt(Rect.new(0, 0, d, d), bmp, texture_rect)
    cutout_circle(cx, cy, radius)
  end
  
  def draw_textured_ellipse(cx, cy, rx, ry, bmp, texture_rect = nil)
    texture_rect ||= bmp.rect
    @@shape_buffer.stretch_blt(Rect.new(0, 0, rx*2, ry*2), bmp, texture_rect)
    cutout_ellipse(cx, cy, rx, ry)
  end
  
  def draw_textured_triangle(x1,y1,x2,y2,x3,y3, bmp, texture_rect = nil)
    texture_rect ||= bmp.rect
    bounds = ShapeHelpers.get_triangle_bounds(x1,y1,x2,y2,x3,y3)
    @@shape_buffer.stretch_blt(bounds, bmp, texture_rect)
    cutout_triangle(x1,y1,x2,y2,x3,y3,bounds)
  end
  
  def draw_textured_convex_shape(vertices, bmp, texture_rect = nil)
    texture_rect ||= bmp.rect
    bounds = ShapeHelpers.get_convex_shape_bounds(vertices)
    @@shape_buffer.stretch_blt(bounds, bmp, texture_rect)
    cutout_convex_shape(vertices,bounds)
  end

private
  
  def cutout_circle(cx, cy, radius)
    d = radius * 2
    r2 = radius * radius
    d.times do |y|
      yy = y-radius
      d.times do |x|
        xx = x-radius
        @@shape_buffer.set_pixel(radius + xx, radius + yy, COLOR_ALPHA) if xx*xx + yy*yy > r2
      end
    end
    blt(cx - radius, cy - radius, @shape_buffer, Rect.new(0,0,d,d))
  end
  
  def cutout_ellipse(cx,cy,rx,ry)
    rx2 = rx*rx
    ry2 = ry*ry
    (ry*2).times do |y|
      yy = y-ry
      (rx*2).times do |x|
        xx = x-rx
        t = Math.atan2(yy,xx)
        r2 = (rx2*ry2) / (rx2 * Math.sin(t)**2 + ry2 * Math.cos(t)**2)
        @@shape_buffer.set_pixel(rx + xx, ry + yy, COLOR_ALPHA) if (xx*xx + yy*yy) > r2
      end
    end
    blt(cx - rx, cy - ry, @shape_buffer, Rect.new(0,0,rx*2,ry*2))
  end
  
  def cutout_triangle(x1,y1,x2,y2,x3,y3,bounds)
    bounds.height.times do |y|
      yy = bounds.y + y
      bounds.width.times do |x|
        xx = bounds.x + x
        next if ShapeHelpers.point_in_convex_shape([[x1,y1],[x2,y2],[x3,y3]],xx,yy)
        @@shape_buffer.set_pixel(xx, yy, COLOR_ALPHA)
      end
    end
    blt(bounds.x, bounds.y, @shape_buffer, bounds)
  end
  
  def cutout_convex_shape(points,bounds)
    bounds.height.times do |y|
      yy = bounds.y + y
      bounds.width.times do |x|
        xx = bounds.x + x
        next if ShapeHelpers.point_in_convex_shape(points,xx,yy)
        @@shape_buffer.set_pixel(xx, yy, COLOR_ALPHA)
      end
    end
    blt(bounds.x, bounds.y, @shape_buffer, bounds)
  end
end