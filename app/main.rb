require 'app/root_scene.rb'
require 'app/campfire.rb'

def init args
  args.state.root_scene = RootScene.new(args)
end

def tick args
  if Kernel.tick_count == 0
    init args
  end

  args.state.root_scene.tick

  args.outputs.primitives << args.state.root_scene.render
end
