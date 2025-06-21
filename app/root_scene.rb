class RootScene
    attr_gtk

    def initialize args
        @args = args
        @background = [
            {x: 0, y: 0, w: 1280, h: 720, r: 255, g: 255, b: 255}.solid!
        ]
    end

    def tick

    end

    def render
        out = @background.clone()

        out
    end
end
