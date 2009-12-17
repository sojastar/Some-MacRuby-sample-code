#
#  BoingController.rb
#  MacRuby BoingX
#
###

class BoingController



	#def timer_fired(timer)
	#	@view.animate
	#end





	def applicationWillFinishLaunching(notification)

		@window	= BoingWindow.alloc.initWithContentRect(NSMakeRect(100.0, 100.0, 640, 400),
														styleMask:NSBorderlessWindowMask,
														backing:NSBackingStoreBuffered,
														defer:false)

		@view	= BoingView.alloc.initWithFrame(NSMakeRect(0.0, 0.0, 640, 400))


		@window.setContentView(@view)

		@window.makeKeyAndOrderFront(nil)


		#@timer	= NSTimer.timerWithTimeInterval(1.0/60.0, target:self, selector:"timer_fired:", userInfo:nil, repeats:true)
		#NSRunLoop.currentRunLoop.addTimer(@timer, forMode:NSDefaultRunLoopMode)
		#NSRunLoop.currentRunLoop.addTimer(@timer, forMode:NSEventTrackingRunLoopMode)

	end


end