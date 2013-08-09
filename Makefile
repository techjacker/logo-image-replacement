MOD_NAME = logo-image-replacement

boil:
	@boil html html-private


###############################
###############################

## DOCS
DOCS_TMPL_DIR = docs-tmpl
MOCHA_MD_DOCS = README_footer.md

############### Build ################
## tmpl
TMPL_DIR = tmpl
# TMPL_CONVERT_CMD = component convert
TMPL_CONVERT_CMD = minstache < 
## build
BUILD_DIR = build
BUILD_COMPILED = $(BUILD_DIR)/$(MOD_NAME).js
BUILD_COMPILED_MIN = $(BUILD_COMPILED:.js=.min.js)
BUILD_COMPILED_STANDALONE = $(BUILD_COMPILED:.js=.standalone.js)
BUILD_COMPILED_CSS = $(BUILD_COMPILED:.js=.css)
BUILD_COMPILED_CSS_MIN = $(BUILD_COMPILED_CSS:.css=.min.css)

## public
PUBLIC_DIR = public
PUBLIC_COMPILED = $(PUBLIC_DIR)/build.js
PUBLIC_COMPILED_MIN = $(PUBLIC_COMPILED:.js=.min.js)
PUBLIC_COMPILED_CSS = $(PUBLIC_COMPILED:.js=.css)
PUBLIC_COMPILED_CSS_MIN = $(PUBLIC_COMPILED_CSS:.css=.min.css)
PUBLIC_ALL = $(PUBLIC_COMPILED_MIN) $(PUBLIC_COMPILED) $(PUBLIC_COMPILED_CSS) $(PUBLIC_COMPILED_CSS_MIN)
## install
COMPONENTJS_CMD = @component build --out $(@D) --name $(basename $(@F))
############### Build ################


######################################
# Release
######################################
# publish: clean public docs test-node lint
publish: public docs lint

docs: build
	@grunt build
	@make clean-readme

lint:
	@./node_modules/.bin/jshint lib

######################################
# Tests
######################################
npm-install-dev: package.json
	@npm install

######################################
# Servers
######################################
# server: npm-install-dev public
server: public-quick
	@serve public
	@echo go to http://localhost:3000

server-test test-browser: npm-install-dev components
	@serve
	@echo go to http://localhost:3000/test

######################################
# Build
######################################

############## public ################
public: build $(PUBLIC_ALL)
public-quick: build-quick $(PUBLIC_ALL) public-images

$(PUBLIC_COMPILED_MIN): $(BUILD_COMPILED_MIN)
	@cp -f $< $@
	@echo $< $@

$(PUBLIC_COMPILED): $(BUILD_COMPILED)
	@echo $< $@
	@cp -f $< $@

$(PUBLIC_COMPILED_CSS): $(BUILD_COMPILED_CSS)
	@cp -f $< $@

$(PUBLIC_COMPILED_CSS_MIN): $(BUILD_COMPILED_CSS_MIN)
	@cp -f $< $@

public-images:
	@for d in $(wildcard $(BUILD_DIR)/*); do \
		[ -d $$d ] && cp -r $$d public/; \
	done

############## build ################
# build: templates components npm-install-dev $(BUILD_COMPILED_MIN)
BUILD_DEPS = templates $(BUILD_COMPILED_CSS_MIN) $(BUILD_COMPILED_MIN)
build: clean components npm-install-dev $(BUILD_DEPS)
build-quick: clean-build $(BUILD_DEPS)

$(BUILD_COMPILED_MIN): $(BUILD_COMPILED)
	@./node_modules/.bin/uglifyjs < $^ > $@

$(BUILD_COMPILED_CSS_MIN): $(BUILD_COMPILED_CSS)
	@yuicompressor $< -o $@

$(BUILD_COMPILED) $(BUILD_COMPILED_CSS):
	$(COMPONENTJS_CMD) $(MOD_NAME)

$(BUILD_COMPILED_STANDALONE):
	$(COMPONENTJS_CMD) --standalone $(MOD_NAME)

############## templates ################
templates:
	@for tmpl in $(wildcard $(TMPL_DIR)/*.tmpl); do \
		$(TMPL_CONVERT_CMD) $$tmpl > $$tmpl.js; \
	done
############## packages ################
components: component.json
	@component install --dev

######################################
# Docs
# run grunt readme
######################################
readme: readme-footer
	@grunt readme-concat

readme-footer:
	@[ -d $(DOCS_TMPL_DIR) ] || mkdir $(DOCS_TMPL_DIR)
	@echo '' >> $(DOCS_TMPL_DIR)/$(MOCHA_MD_DOCS)
	@echo '## License' >> $(DOCS_TMPL_DIR)/$(MOCHA_MD_DOCS)


######################################
# Housekeeping
######################################
size: build
	@echo "$(BUILD_COMPILED): `wc -c $(BUILD_COMPILED) | sed 's/ .*//'`"
	@echo "$(BUILD_COMPILED_MIN): `gzip -c $(BUILD_COMPILED_MIN) | wc -c`"

clean: clean-readme clean-build
	@rm -f *.log*
	@rm -rf components

clean-build:
	@rm -rf build $(PUBLIC_DIR)/build.* $(TMPL_DIR)/*.js

clean-readme:
	@find $(DOCS_TMPL_DIR) -maxdepth 1 -type f ! -iname '*.tmpl' -delete

.PHONY: readme clean clean-* npm-install-dev release size server *-quick boil public-images