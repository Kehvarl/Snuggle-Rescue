class RootScene
    attr_gtk

    def initialize args
        @args = args
        @campfire = Campfire.new(3840/2, 2160/2)
        @player = {x: 3840/2+64, y: 2160/2+64, w: 16, h: 16,
                   anchor_x: 0.5, anchor_y: 0.5,
                   path: "sprites/circle/green.png"}.sprite!
        @camera = {x: 3840/2, y: 2160/2, zoom: 1.0}
        @tiles = []
        # useful tiles:
        # Empty
        # 9,12
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
        0.step(3840, 16) do |x|
            0.step(2160, 16) do |y|
                @tiles << {x: x, y: y, w: 16, h: 16,
                          source_x: 9*16, source_y: 0*16,
                          source_w: 16, source_h: 16,
                          path: "sprites/snow_islands.png"}.sprite!
            end
        end

        x = @player.x
        y = @player.y
        100.times do
            if rand(10) < 5
                if rand(10) < 5
                    x -= 16
                else
                    x += 16
                end
            else
                if rand(10) < 5
                    y -= 16
                else
                    y += 16
                end
            end
            @tiles << {x: x, y: y, w: 16, h: 16,
                        source_x: 12*16, source_y: 6*16,
                        source_w: 16, source_h: 16,
                        path: "sprites/snow_islands.png"}.sprite!
        end
        generate_background
    end

    def generate_background
        outputs[:background].w = 3840
        outputs[:background].h = 2160
        outputs[:background].background_color = [64, 64, 64, 255]
        outputs[:background].primitives << @tiles
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
        outputs[:scene].transient = true
        outputs[:scene].w = 3840
        outputs[:scene].h = 2160
        outputs[:scene].background_color = [64, 64, 64, 255]
        outputs[:scene].primitives << {x:0, y:0, w:3840, h:2160, path: :background }.sprite!
        outputs[:scene].primitives << @campfire.render()
        outputs[:scene].primitives << @player

    end

    def render
        {x: 0, y: 0, w: 1280, h: 720, path: :scene,
         source_x: @camera.x-640, source_y: @camera.y-360,
         source_w: 1280, source_h: 720}.sprite!
    end
end
