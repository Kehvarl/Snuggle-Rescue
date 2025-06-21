class RootScene
    attr_gtk

    def initialize args
        @args = args
        @background = [
            {x: 0, y: 0, w: 1280, h: 720, r: 64, g: 64, b: 64}.solid!
        ]
        @campfire = Campfire.new()
    end

    def tick
        @campfire.tick

    end

    def render
        out = @background.clone()
        out << @campfire.render()
        out
    end
end
