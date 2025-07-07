class RootScene
    attr_gtk

    def initialize args
        @args = args
        @campfire = Campfire.new(3840/2, 2160/2)
        @player = {x: 3840/2+64, y: 2160/2+64, w: 16, h: 16,
                   anchor_x: 0.5, anchor_y: 0.5,
                   path: "sprites/circle/green.png",
                   friend: false}.sprite!
        @camera = {x: 3840/2, y: 2160/2, zoom: 1.0}
        @tiles = []
        @paths = []
        @obstacles  = []
        @friends_count = 12
        @friends = []
        @rescued = []
        generate_map
        generate_background
    end

    def generate_map
        0.step(3840, 16) do |x|
            0.step(2160, 16) do |y|
                @tiles << {x: x, y: y, w: 16, h: 16,
                           anchor_x: 0.5, anchor_y: 0.5,
                           source_x: 9*16, source_y: 0*16,
                           source_w: 16, source_h: 16,
                           path: "sprites/snow_islands.png"}.sprite!
            end
        end
        generate_map_paths
        generate_map_obstacles
        populate_friends
    end

    def generate_map_paths
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
    end

    def generate_map_obstacles
        500.times do
            x = rand(240)
            y = rand(134) + 1
            if @args.geometry.find_all_intersect_rect({x:x, y:y, w:16, h:32}, @paths).empty?
                tree = rand(3) + 15
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
    end

    def populate_friends
        while @friends.size < @friends_count do
            x = rand(240)
            y = rand(134) + 1
            if @args.geometry.find_all_intersect_rect({x:x, y:y, w:16, h:16}, @obstacles).empty?
                @friends << {
                    x: x*16, y: y*16, w: 16, h: 16,
                    anchor_x: 0.5, anchor_y: 0.5,
                    path: "sprites/circle/violet.png"
                }.sprite!
            end
        end
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
        calc_player
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

    def calc_player
        # Instead of picking up a friend, we could make them follow the player
        # Need either some pathfinding or for the player to lay down a "trail" the friend can follow
        # Since movement is not grid-aligned, pathfinding might be better
        # Will look up an Astar implementation for DRGTK.
        if not @player.friend
            found = @args.geometry.find_all_intersect_rect @player, @friends
            if found.count > 0
                @player.friend = found[0]
                @friends.delete(found[0])
            end
        elsif @args.geometry.distance(@player, @campfire.fire) <= @campfire.radius
            f = @player.friend
            place_rescued f
            @player.friend = false
        end
    end


    def place_rescued friend
        deg = (360.0 / @friends_count) * (@rescued.size + 1)
        rad = deg * Math::PI / 180
        friend.x = 128 * Math.sin(rad) + @campfire.fire.x
        friend.y = 128 * Math.cos(rad) + @campfire.fire.y
        @campfire.radius += 16
        @rescued << friend
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
        outputs[:scene].primitives << @friends
        outputs[:scene].primitives << @rescued
        outputs[:scene].primitives << @player
    end

    def render
        out = [
            {x: 0, y: 0, w: 1280, h: 720, path: :scene,
            source_x: @camera.x-640, source_y: @camera.y-360,
            source_w: 1280, source_h: 720}.sprite!
        ]
        if @rescued.size == @friends_count
            out << {x: 320, y: 200, w: 640, h: 240, r: 128, g: 128, b: 128}.solid!
            out << {x: 600, y: 380, w: 640, h: 320, text: "Hurray!"}.label!
            out << {x: 480, y: 360, w: 640, h: 320, text: "You found all your friends!"}.label!
        end
        out
    end
end
