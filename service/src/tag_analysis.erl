-module(tag_analysis).

-export([init/3]).
-export([rest_init/2]).
-export([malformed_request/2]).
-export([options/2]).
-export([allowed_methods/2]).
-export([content_types_provided/2]).
-export([read_json/2]).

-export([generics/1, related/1]).

-record(state, {tag}).

init(_Transport, _Req, _Opts) ->
    {upgrade, protocol, cowboy_rest}.

rest_init(Req, _Opts) ->
    {ok, add_cors(Req), #state{}}.

malformed_request(Req, State) ->
    {Tag, Req0} = cowboy_req:binding(tag, Req),
    case Tag of
        undefined -> {true, Req0, State};
        <<>> -> {true, Req0, State};
        _ -> {false, Req0, State#state{tag = Tag}}
    end.

allowed_methods(Req, State) ->
    {[<<"GET">>], Req, State}.

options(Req, State) ->
    {ok, add_cors_options(Req), State}.

content_types_provided(Req, State) ->
    {[{<<"application/json">>, read_json}], Req, State}.

synonyms(Tag) ->
    Q = <<"select distinct t1.name from tags t1 join synonyms s1 on t1.id=s1.tag_id join synonyms s0 on s1.id=s0.id join tags t0 on s0.tag_id=t0.id where t0.name=$1 union select distinct t.name from wordnet_synonyms ws join synonyms s on s.id=ws.synonym_id join tags t on s.tag_id=t.id where ws.word_ts=to_tsvector($1)::text">>,
    {ok, _, R} = tag_analysis_pg:equery(tag_analysis_pool, Q, [Tag]),
    [Synonym || {Synonym} <- R].

generics(Tag) ->
    Q = <<"select distinct t.name from wordnet_generics wg join synonyms s on s.id=wg.generic_id join tags t on s.tag_id=t.id where wg.word_ts=to_tsvector($1)::text">>,
    {ok, _, R} = tag_analysis_pg:equery(tag_analysis_pool, Q, [Tag]),
    [Generic || {Generic} <- R].

related(Tag) ->
    Q = <<"select distinct t.name from wordnet_related wr join synonyms s on s.id=wr.related_id join tags t on s.tag_id=t.id where wr.word_ts=to_tsvector($1)::text">>,
    {ok, _, R} = tag_analysis_pg:equery(tag_analysis_pool, Q, [Tag]),
    [Generic || {Generic} <- R].

read_json(Req, #state{tag = Tag} = State) ->
    {jiffy:encode({[{<<"synonyms">>, synonyms(Tag)}, {<<"generics">>, generics(Tag)}, {<<"related">>, related(Tag)}]}), Req, State}.

add_cors(Req) ->
    cowboy_req:set_resp_header(<<"access-control-allow-origin">>, <<"http://tags.connect.me">>,
    cowboy_req:set_resp_header(<<"access-control-allow-methods">>, <<"OPTIONS, GET, PUT, DELETE">>,
    cowboy_req:set_resp_header(<<"access-control-allow-credentials">>, <<"true">>,
    cowboy_req:set_resp_header(<<"access-control-allow-headers">>, <<"origin, content-type, accept">>, Req)))).

add_cors_options(Req) ->
    cowboy_req:set_resp_header(<<"access-control-max-age">>, <<"60">>, Req).
