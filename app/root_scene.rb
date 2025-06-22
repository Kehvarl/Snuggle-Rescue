class RootScene
    attr_gtk

    def initialize args
        @args = args
        @campfire = Campfire.new(3840/2, 2160/2)
        @player = {x: 3840/2, y: 2160/2, w: 32, h: 32,
                   anchor_x: 0.5, anchor_y: 0.5,
                   path: "sprites/circle/green.png"}.sprite!
    end

    def tick
        get_input
        @campfire.tick
        render_scene
    end

    def get_input
        if inputs.keyboard.left
            @player.x -=3
        elsif inputs.keyboard.right
            @player.x += 3
        end
        if inputs.keyboard.up
            @player.y +=3
        elsif inputs.keyboard.down
            @player.y -= 3
        end
    end

    def render_scene
        outputs[:scene].transient!
        outputs[:scene].w = 3840
        outputs[:scene].h = 2160
        outputs[:scene].background_color = [64, 64, 64, 255]
        outputs[:scene].primitives << @campfire.render()
        outputs[:scene].primitives << @player
    end

    def render
        {x: 0, y: 0, w: 1280, h: 720, path: :scene,
         tile_x: (@player.x - 640), tile_y: (@player.y -  360),
         tile_w: 1280, tile_h: 720}.sprite!
    end
end
