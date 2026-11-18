.PHONY: help install check test demo run-mcp run-agent clean

RECIPE_DIR = examples/bodhan-tool-server-agent

help:
	@$(MAKE) -C $(RECIPE_DIR) help

install:
	@$(MAKE) -C $(RECIPE_DIR) install

check:
	@$(MAKE) -C $(RECIPE_DIR) check

test:
	@$(MAKE) -C $(RECIPE_DIR) test

demo:
	@$(MAKE) -C $(RECIPE_DIR) demo

run-mcp:
	@$(MAKE) -C $(RECIPE_DIR) run-mcp

run-agent:
	@$(MAKE) -C $(RECIPE_DIR) run-agent

clean:
	@$(MAKE) -C $(RECIPE_DIR) clean
