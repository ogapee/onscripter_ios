all: \
	$(INSTALL_PATH)/lib/libfreetype.a \
	$(INSTALL_PATH)/lib/libmad.a \
	$(INSTALL_PATH)/lib/libogg.a \
	$(INSTALL_PATH)/lib/libvorbisidec.a \
	$(INSTALL_PATH)/lib/liblua.a \
	$(INSTALL_PATH)/lib/libsmpeg.a

$(INSTALL_PATH)/lib/libfreetype.a:
	cd freetype-2.4.8; ./configure CC=$(SDK_CC) CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" --host=$(HOST) --disable-shared --prefix=$(INSTALL_PATH)
	make -C freetype-2.4.8
	make -C freetype-2.4.8 install

$(INSTALL_PATH)/lib/libmad.a:
	cd libmad-0.15.1b; sh ./configure CC=$(SDK_CC) CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" SDL_CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" --host=$(HOST) --disable-shared --prefix=$(INSTALL_PATH) --disable-aso
	make -C libmad-0.15.1b
	make -C libmad-0.15.1b install

$(INSTALL_PATH)/lib/libogg.a:
	cd libogg-1.3.1; ./configure CC=$(SDK_CC) CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" SDL_CFLAGS="-isysroot $(SDK_PATH)" --host=$(HOST) --disable-shared --prefix=$(INSTALL_PATH)
	make -C libogg-1.3.1
	make -C libogg-1.3.1 install

$(INSTALL_PATH)/lib/libvorbisidec.a:
	cd libvorbisidec-1.0.2+svn18153; ./autogen.sh CC=$(SDK_CC) CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" SDL_CFLAGS="-isysroot $(SDK_PATH)" OGG_CFLAGS="-I$(INSTALL_PATH)/include" OGG_LIBS="-L$(INSTALL_PATH)/lib" --host=$(HOST) --disable-shared --prefix=$(INSTALL_PATH)
	make -C libvorbisidec-1.0.2+svn18153
	make -C libvorbisidec-1.0.2+svn18153 install

$(INSTALL_PATH)/lib/liblua.a:
	make -C lua-5.1.5 macosx CC=$(SDK_CC) CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" INSTALL_TOP=$(INSTALL_PATH)
	make -C lua-5.1.5 install CC=$(SDK_CC) CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" INSTALL_TOP=$(INSTALL_PATH)

$(INSTALL_PATH)/lib/libsmpeg.a:
	make -C smpeg-0.4.5+cvs20030824 -f Makefile.ons CC=$(SDK_CC) CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" INSTALL_TOP=$(INSTALL_PATH)
	make -C smpeg-0.4.5+cvs20030824 -f Makefile.ons install CC=$(SDK_CC) CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" INSTALL_TOP=$(INSTALL_PATH)

clean:
	make -C freetype-2.4.8 clean
	make -C libmad-0.15.1b clean
	make -C libogg-1.3.1 clean
	make -C libvorbisidec-1.0.2+svn18153 clean
	make -C lua-5.1.5 clean
	make -C smpeg-0.4.5+cvs20030824 -f Makefile.ons clean
	-rm $(INSTALL_PATH)/lib/libfreetype.a
	-rm $(INSTALL_PATH)/lib/libmad.a
	-rm $(INSTALL_PATH)/lib/libogg.a
	-rm $(INSTALL_PATH)/lib/libvorbisidec.a
	-rm $(INSTALL_PATH)/lib/liblua.a
	-rm $(INSTALL_PATH)/lib/libsmpeg.a
