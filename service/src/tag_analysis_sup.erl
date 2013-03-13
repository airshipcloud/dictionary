-module(tag_analysis_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

rest() ->
    RestDispatch = [{'_', [
        {[<<"tag">>, tag], tag_analysis, []}
    ]}],
    RestConfig = [rest_listener, 100,
        [{port, 10001}],
        [{dispatch, RestDispatch}]],
    {rest, {cowboy, start_http, RestConfig}, permanent, 5000, supervisor, dynamic}.

init([]) ->
    Pool = poolboy:child_spec(tag_analysis_pool,
        [
            {name, {local, tag_analysis_pool}},
            {worker_module, tag_analysis_pg},
            {size, 3},
            {max_overflow, 10}
        ],
        [
            {hostname, "127.0.0.1"},
            {database, "tag_analysis"},
            {username, "tag_analysis"},
            {password, "y7DrtF48bc"}
        ]),
    {ok, { {one_for_one, 5, 10}, [Pool, rest()]} }.

