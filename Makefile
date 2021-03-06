###
#
# Made by: Julien Fouilhé <julien.fouilhe@gmail.com>
# This Makefile reads dependencies from files and recompiles files
# which are dependant of a modified file.
# It also moves object files to a hidden directory.
#
###

EXEC = scattr

CXX = g++

CXXFLAGS = -W -Wall -Werror -Wextra -pedantic -I. -I./include -c -std=c++11 -O2 \
					 -DBOOST_ALL_DYN_LINK \
					 -Dnblog="BOOST_LOG(AdaptersFactory::getInstance()->logger())"

# BOOST_SUFFIX = -mt

LDFLAGS = -lboost_program_options$(BOOST_SUFFIX) -lboost_system$(BOOST_SUFFIX) \
					-lboost_thread$(BOOST_SUFFIX) -lboost_filesystem$(BOOST_SUFFIX)  \
					-lboost_date_time$(BOOST_SUFFIX) -lboost_log_setup$(BOOST_SUFFIX) \
					-lboost_log$(BOOST_SUFFIX) \
					-lcppunit -lamqpcpp -lmacgpusher -lcrypto -lssl -lpthread

BIN_DIR = bin

SRCDIRS := $(shell find . -name '*.cpp' -exec dirname {} \; | uniq)
OBJDIR = .dobjects

SRCS := $(wildcard src/*.cpp)
OBJS := $(patsubst %.cpp,$(OBJDIR)/%.o,$(SRCS))
DEPS = $(patsubst %.cpp,$(OBJDIR)/%.d,$(SRCS))

SRCS_ := $(wildcard src/*.cpp adapters/*/*.cpp)
OBJS_ := $(patsubst %.cpp,$(OBJDIR)/%.o,$(SRCS_))

SRCS_TESTS := $(wildcard tests/*.cpp)
OBJS_TESTS := $(patsubst %.cpp,$(OBJDIR)/%.o,$(SRCS_TESTS))
DEPS_TESTS := $(patsubst %.cpp,$(OBJDIR)/%.d,$(SRCS_TESTS))

SAVES = ./.save

all: $(EXEC)

$(EXEC): buildrepo $(OBJS) build_adapters
	@echo "Building" $@
	@mkdir -p $(BIN_DIR)
	@echo "$@: Linking objects files... "
	@$(CXX) -o $(BIN_DIR)/$@ $(OBJS_) $(LDFLAGS)
	@echo "Linking done."

test: buildrepo $(OBJS) $(OBJS_TESTS)
	@echo "Building " $@
	@mkdir -p $(BIN_DIR)
	@echo "$@: Linking objects files... "
	@$(CXX) -o $(BIN_DIR)/$@ $(filter-out $(OBJDIR)/src/main.o, $(OBJS_)) $(OBJS_TESTS) $(LDFLAGS)
	@echo "Linking done. Launching tests..."
	@echo "---------"
	@$(BIN_DIR)/$@
	@echo "---------"

$(OBJDIR)/%.o: %.cpp
	@echo "Generating dependencies for $<"
	@$(call make-depend,$<,$@,$(subst .o,.d,$@))
	@echo "Compiling $<"
	@$(CXX) $(CXXFLAGS) $< -o $@

build_adapters:
	@make -C ./adapters

clean:
	@echo "Erasing objects files"
	@$(RM) -r $(OBJDIR)

fclean: clean
	@echo "Erasing executable(s)"
	@$(RM) $(EXEC)

buildrepo:
	@$(call make-repo)

define make-repo
for dir in $(SRCDIRS); \
do \
mkdir -p $(OBJDIR)/$$dir; \
done
endef

define make-depend
$(CXX) -MM \
-MF $3 \
-MP \
-MT $2 \
$(CXXFLAGS) \
$(INCLUDES) \
$1
endef

ifneq "$(MAKECMDGOALS)" "clean"
-include $(DEPS)
endif

re: fclean all
