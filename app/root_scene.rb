class RootScene
    attr_gtk

    def initialize args
        @args = args
        @campfire = Campfire.new()
    end

    def tick
        @campfire.tick
        render_scene
    end

    def render_scene
        outputs[:scene].transient!
        outputs[:scene].w = 1500
        outputs[:scene].h = 1500
        outputs[:scene].background_color = [64, 64, 64, 255]
        outputs[:scene].primitives << @campfire.render()
    end

    def render
        {x: 0, y: 0, w: 1280, h: 720, path: :scene,
         tile_x: (750 - 640), tile_y: (750 - 360),
         tile_w: 1280, tile_h: 720}.sprite!
    end
end
