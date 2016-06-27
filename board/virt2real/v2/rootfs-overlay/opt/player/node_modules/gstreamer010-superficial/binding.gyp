{
  "targets": [
    {
      "target_name": "gstreamer010-superficial",
      "sources": [ "gstreamer.cc" ],
	  "libraries": [
            '<!@(pkg-config gstreamer-0.10 --libs)',
            '<!@(pkg-config gstreamer-app-0.10 --libs)'
          ],
      "include_dirs": [
            '<!@(pkg-config gstreamer-0.10 --cflags-only-I | sed s/-I//g)',
            '<!@(pkg-config gstreamer-app-0.10 --cflags-only-I | sed s/-I//g)'
          ],
    }
  ]
}
