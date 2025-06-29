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
        @paths = []
        @obstacles  = []
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
                           anchor_x: 0.5, anchor_y: 0.5,
                           source_x: 9*16, source_y: 0*16,
                           source_w: 16, source_h: 16,
                           path: "sprites/snow_islands.png"}.sprite!
            end
        end
        s = [1848, 1008, 13, 9]
        [[1972, 1008, 14, 8], [1972, 1132, 13, 7], [1848, 1132, 12, 8], [1848, 1008, 14, 7]].each do |t|
            dx = t[0] <=> s[0]
            dy = t[1] <=> s[1]
            x = s[0] + (16 * dx)
            y = s[1] + (16 * dy)
            loop do
                @paths << {
                    x: x, y: y, w: 16, h: 16,
                    anchor_x: 0.5, anchor_y: 0.5,
                    source_x: s[2] * 16, source_y: s[3] * 16,
                    source_w: 16, source_h: 16,
                    path: "sprites/snow_islands.png"
                }.sprite!
                break if x + (16 * dx) == t[0] && y + (16 * dy) == t[1]
                x += dx unless x == t[0]
                y += dy unless y == t[1]
            end
            s = t
        end
        [[1972, 1008, 14, 7], [1972, 1132, 14, 9], [1848, 1132, 12, 9], [1848, 1008, 12, 7]].each do |t|
            @paths << {
                x: t[0], y: t[1], w: 16, h: 16,
                anchor_x: 0.5, anchor_y: 0.5,
                source_x: (t[2]) * 16, source_y: (t[3]) * 16,
                source_w: 16, source_h: 16,
                path: "sprites/snow_islands.png"
            }.sprite!
        end
        500.times do
            x = rand(240)
            y = rand(134) + 1
            if @args.geometry.find_all_intersect_rect({x:x, y:y, w:16, h:32}, @paths).empty?
                tree = rand(4) + 15
                @obstacles << {
                    x: x*16, y: y*16, w: 16, h: 16,
                    anchor_x: 0.5, anchor_y: 0.5,
                    source_x: tree * 16, source_y: 12 * 16,
                    source_w: 16, source_h: 16,
                    path: "sprites/snow_islands.png"
                }.sprite!
                @obstacles << {
                    x: x*16, y: (y-1) * 16, w: 16, h: 16,
                    anchor_x: 0.5, anchor_y: 0.5,
                    source_x: tree * 16, source_y: 11 * 16,
                    source_w: 16, source_h: 16,
                    path: "sprites/snow_islands.png"
                }.sprite!
            end
        end
        generate_background
    end

    def generate_background
        outputs[:background].w = 3840
        outputs[:background].h = 2160
        outputs[:background].background_color = [64, 64, 64, 255]
        outputs[:background].primitives << @tiles

        outputs[:background].primitives << @paths
        outputs[:background].primitives << @obstacles.sort_by { |t| -t.y }

    end

    def tick
        process_input
        @campfire.tick
        calc_camera
        render_scene
    end

    def process_input
        dx = 0
        if inputs.keyboard.left
            dx = -3
        elsif inputs.keyboard.right
            dx =  3
        end

        dy = 0
        if inputs.keyboard.up
            dy =  3
        elsif inputs.keyboard.down
            dy = -3
        end

        temp = @player.clone
        temp.x += dx
        temp.x = temp.x.clamp(8, 3832)

        hits = @args.geometry.find_all_intersect_rect temp, @obstacles
        if hits.empty?
            @player.x = temp.x
        end

        temp = @player.clone
        temp.y += dy
        temp.y = temp.y.clamp(8, 2152)

        hits = @args.geometry.find_all_intersect_rect temp, @obstacles
        if hits.count == 0
            @player.y = temp.y
        end
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
