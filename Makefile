MNESIADIR = /usr/local/otp_src_R15B/lib/mnesia

all: deps compile

compile:
	rebar compile

deps:
	rebar get-deps

clean:
	rebar clean

test:
	rebar skip_deps=true eunit

start:
	erl -sname mpb_test -pa ebin deps/*/ebin $(MNESIADIR)/examples/ $(MNESIADIR)/src/ $(MNESIADIR)/ebin/ $(MNESIADIR)/test/

analyze: compile
	rebar analyze skip_deps=true