target:makefile

copyfile: $(amakeroot)/unix/copyfile.tpl $(prjfile)
	@pump $@ $(amakeroot)/unix/copyfile.tpl $(prjfile)
	@chmod +x copyfile

project.env: copyfile
	@echo \<system prjfile=\"$(prjfile)\"  libs=\"\" cppflags=\"\" ldflags=\"\" arflags=\"\"\> >$@
	@cat $(prjfile) >> $@
	@echo \<package\> >> $@
	@copyfile $@
	@echo \</package\> >> $@
	@echo \</system\> >> $@
	@rm copyfile

makefile: $(amakeroot)/macos/makefile.tpl project.env
	@pump $@ $(amakeroot)/macos/makefile.tpl project.env
	@rm project.env
