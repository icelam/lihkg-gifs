.PHONY: first-release release

# Create the first release
first-release:
	npx standard-version --first-release

# Create a new release
release:
	npx standard-version
