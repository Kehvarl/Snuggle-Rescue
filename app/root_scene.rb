class RootScene
    attr_gtk

    def initialize args
        @args = args
        @campfire = Campfire.new(3840/2, 2160/2)
        @player = {x: 3840/2, y: 2160/2, w: 32, h: 32,
                   anchor_x: 0.5, anchor_y: 0.5,
                   path: "sprites/circle/green.png"}.sprite!
        @camera = {x: 3840/2, y: 2160/2, zoom: 1.0}
        @tiles = []
        # useful tiles:
        # Empty
        # 0,0
        # Path Ends
        # 12,12 13,12 14,12 < > ^
        # 12,11       14,11 ^   v
        # 12,10 13,10 14,10 v < >
        # Paths
        #      13,11          +
        # 12,9 13,9 14,9
        # 12,8      14,8
        # 12.7 13,7 14,7
        # Path T connectors
        # 12,6 13,6         | T
        # 12,5 13,5         - |
        1280.step(2560, 16) do |x|
            720.step(1440, 16) do |y|
                @tiles << {x: x, y: y, w: 16, h: 16,
                          tile_x: 9*16, tile_y: 12*16,
                          tile_w: 16, tile_h: 16,
                          path: "sprites/snow_islands.png"}.sprite!
            end
        end


    end

    def tick
        get_input
        @campfire.tick
        calc_camera
        render_scene
    end

    def get_input
        if inputs.keyboard.left
            @player.x -=3
        elsif inputs.keyboard.right
            @player.x += 3
        end
        @player.x = @player.x.clamp(8, 3832)
        if inputs.keyboard.up
            @player.y +=3
        elsif inputs.keyboard.down
            @player.y -= 3
        end
        @player.y = @player.y.clamp(8, 2152)

    end

    def calc_camera
        @camera.x = @player.x.clamp(640, 3200)
        @camera.y = @player.y.clamp(360, 1800)
    end

    def render_scene
        outputs[:scene].transient!
        outputs[:scene].w = 3840
        outputs[:scene].h = 2160
        outputs[:scene].background_color = [64, 64, 64, 255]
        outputs[:scene].primitives << @tiles
        outputs[:scene].primitives << @campfire.render()
        outputs[:scene].primitives << @player

    end

    def render
        {x: 0, y: 0, w: 1280, h: 720, path: :scene,
         tile_x: @camera.x-640, tile_y: @camera.y-360,
         tile_w: 1280, tile_h: 720}.sprite!
    end
end
