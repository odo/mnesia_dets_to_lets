%% @author Florian Odronitz <fo@twofloats.com>

-module(dets_to_lets).
-export([
	init/0,
	test/1
]).

% patch all functions of dets relevant to mnesia
% with the corresponding functions in lets

% the list of functions was obtained by running
% cd /usr/local/otp_src_R15B/lib/mnesia/src
% grep -h -o -P "dets:[a-z|_]*" *.erl|sort|uniq
init() ->
	FunMap = [
		% {{dets,bchunk},{lets,bchunk},2},
		% {{dets,close},{lets,close},1},
		{{dets,delete},{lets,delete},2},
		{{dets,delete_all_objects},{lets,delete_all_objects},1},
		% {{dets,delete_object},{lets,delete_object},2},
		{{dets,first},{lets,first},1},
		% {{dets,from_ets},{lets,from_ets},2},
		{{dets,info},{lets,info},1},
		% {{dets,init_table},{lets,init_table},2},
		{{dets,insert},{lets,insert},2},
		% {{dets,is_compatible_bchunk_format},{lets,is_compatible_bchunk_format},2},
		{{dets,lookup},{lets,lookup},2},
		{{dets,match},{lets,match},1},
		{{dets,match},{lets,match},2},
		{{dets,match},{lets,match},3},
		{{dets,match_delete},{lets,match_delete},2},
		{{dets,match_object},{lets,match_object},1},
		{{dets,match_object},{lets,match_object},2},
		{{dets,match_object},{lets,match_object},3},
		{{dets,next},{lets,next},2},
		% {{dets,open_file},{lets,open_file},1},
		% {{dets,open_file},{lets,open_file},2},
		% {{dets,repair_continuation},{lets,repair_continuation},2},
		% {{dets,safe_fixtable},{lets,safe_fixtable},2},
		{{dets,select},{lets,select},1},
		{{dets,select},{lets,select},2},
		{{dets,select},{lets,select},3}
		% {{dets,slot},{lets,slot},2},
		% {{dets,to_ets},{lets,to_ets},2},
		% {{dets,traverse},{lets,traverse},2},
		% {{dets,update_counter},{lets,update_counter},3},
		% {{dets,view},{lets,view},1}
	],
 	ModsUniq = lists:usort([Mod||{{Mod, _}, _, _} <- FunMap]),
	[setup_mod(Mod) || Mod <- ModsUniq],
	[patch(Mod, Function, MockMod, MockFunction, Arity) || {{Mod, Function}, {MockMod, MockFunction}, Arity} <- FunMap].

% get module ready for mocking
setup_mod(Mod) ->
	error_logger:info_msg("~p: Setting up ~p.\n", [?MODULE, Mod]),
	meck:new(Mod, [unstick, passthrough]).

% check and patch one function with another
patch(Mod, Function, MockMod, MockFunction, Arity) ->
	check(Mod, Function, MockMod, MockFunction, Arity),
	do_patch(Mod, Function, MockMod, MockFunction, Arity).

% patch one function with another
do_patch(Mod, Function, MockMod, MockFunction, Arity = 1) ->
	Mock =
	fun
		(Arg1) ->
			mock_msg(Mod, Function, MockMod, MockFunction, Arity),
			MockMod:MockFunction(Arg1)
    end,
    mock(Mod, Function, Mock);

do_patch(Mod, Function, MockMod, MockFunction, Arity = 2) ->
	Mock =
	fun
		(Arg1, Arg2) ->
			mock_msg(Mod, Function, MockMod, MockFunction, Arity),
			MockMod:MockFunction(Arg1, Arg2)
    end,
    mock(Mod, Function, Mock);

do_patch(Mod, Function, MockMod, MockFunction, Arity = 3) ->
	Mock =
	fun
		(Arg1, Arg2, Arg3) ->
			mock_msg(Mod, Function, MockMod, MockFunction, Arity),
			MockMod:MockFunction(Arg1, Arg2, Arg3)
    end,
    mock(Mod, Function, Mock).

mock(Mod, Function, Mock) ->
	meck:expect(Mod, Function, Mock).

% check if both functions are exported
check(Mod, Function, MockMod, MockFunction, Arity) ->
	case lists:member( {Function, Arity}, Mod:module_info(exports)) of
		true -> ok;
		false -> throw({function_not_exported, {Mod, Function, Arity}})
	end,
	case lists:member( {MockFunction, Arity}, MockMod:module_info(exports)) of
		true -> ok;
		false -> throw({function_not_exported, {MockMod, MockFunction, Arity}})
	end.

% a debugging message
mock_msg(Mod, Function, MockMod, MockFunction, Arity) ->
	error_logger:info_msg("~p: Using mocked call to {~p, ~p, ~p} instead of {~p, ~p, ~p}.\n", [?MODULE, MockMod, MockFunction, Arity, Mod, Function, Arity]).

test(Test) -> mt:t(Test).
