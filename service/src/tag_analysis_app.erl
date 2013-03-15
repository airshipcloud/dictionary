-module(tag_analysis_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    Sup = tag_analysis_sup:start_link(),
    error_logger:info_msg("~n==============================~nService running on http://~s:~p~n==============================~n", ["localhost", 10001]),
    Sup.

stop(_State) ->
    ok.
