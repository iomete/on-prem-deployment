# Define the target repository
TARGET_REPO := iomete

# Read the list of images from an external file
IMAGES := $(shell cat docker-images.list)

# Generate a list of indices
INDICES := $(shell seq 1 $(words $(IMAGES)))

# Default target
.PHONY: all
all: $(INDICES)

# Pattern rule for processing each image
.PHONY: $(INDICES)
$(INDICES):
	$(eval IMAGE=$(word $@,$(IMAGES)))
	$(eval REPO_TAG=$(subst /, ,$(IMAGE)))
	$(eval REPO_COUNT=$(words $(REPO_TAG)))
	$(eval IMAGE_NAME_TAG=$(if $(filter 2,$(REPO_COUNT)),$(word 2, $(REPO_TAG)),$(word 2, $(REPO_TAG))/$(word 3, $(REPO_TAG))))
	@echo "Processing image $(IMAGE)"
	# Pull the image from the source repository
	docker pull $(IMAGE)
	# Tag the image for the target repository
	docker tag $(IMAGE) $(TARGET_REPO)/$(IMAGE_NAME_TAG)
	# Push the image to the target repository
	docker push $(TARGET_REPO)/$(IMAGE_NAME_TAG)