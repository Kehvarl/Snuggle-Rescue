class Campfire
    attr_sprite
    attr_accessor :fire, :light, :radius

    def initialize x = 750, y = 750
        @radius = 300
        @fire = { anchor_x: 0.5, anchor_y: 0.5,
                  x: x, y: y, w: 50, h: 50,
                  tile_w: 80, tile_h: 80, tile_x: 0, tile_y: 0,
                  path: "sprites/hexagon/orange.png"}

        @light = { anchor_x: 0.5, anchor_y: 0.5,
                   x: x, y: y, w: @radius * 2, h: @radius * 3,
                   tile_w: 80, tile_h: 80, tile_x: 0, tile_y: 0,
                   r: 255, g: 128, b: 128, a: 32,
                   path: "sprites/circle/white.png",
                   countdown: 7, countfrom: 20}
    end

    def tick
        @light.countdown -= 1
        if @light.countdown <= 0
            @light.countdown = rand(@light.countfrom/2) + @light.countfrom/2
            light_tick
        end
    end

    def light_tick
        r = rand(16) + @radius * 2
        @light.w = r
        @light.h = r
        @light.r = rand(32) + 211
        @light.g = rand(32) + 191
        @light.b = rand(16) + 72
        @light.a = rand(16) + 16
    end

    def render
        [ @fire, @light ]
    end
end

