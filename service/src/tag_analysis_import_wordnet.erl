-module(tag_analysis_import_wordnet).

-export([do/1]).

do(ThesaurusFileName) ->
    {ok, FileDev} = file:open(ThesaurusFileName, [read]),
    ok = read_line(FileDev),
    ok.

read_line(FileDev) ->
    case file:read_line(FileDev) of
        eof ->
            ok;
        {ok, Line} ->
            Tokens = string:tokens(Line, ","),
            Word = hd(Tokens),
            Terms = lists:nthtail(3, Tokens),
            {Syns, Gens, Rels} = lists:foldl(fun(Term, {SynTerms, GenTerms, RelTerms}) ->
                case string:str(Term, "(generic term)") of
                    0 ->
                        case string:str(Term, "(related term)") of
                            0 ->
                                {[list_to_binary(Term) | SynTerms], GenTerms, RelTerms};
                            Pos ->
                                {SynTerms, GenTerms, [list_to_binary(string:substr(Term, 1, Pos - 2)) | RelTerms]}
                        end;
                    Pos ->
                        {SynTerms, [list_to_binary(string:substr(Term, 1, Pos - 2)) | GenTerms], RelTerms}
                end
            end, {[], [], []}, Terms),
            Q0 = <<"select insert_wordnet_synonyms($1::text, $2::text[])">>,
            {ok, _, _} = tag_analysis_pg:equery(tag_analysis_pool, Q0, [Word, Syns]),
            Q1 = <<"select insert_wordnet_generics($1::text, $2::text[])">>,
            {ok, _, _} = tag_analysis_pg:equery(tag_analysis_pool, Q1, [Word, Gens]),
            Q2 = <<"select insert_wordnet_relateds($1::text, $2::text[])">>,
            {ok, _, _} = tag_analysis_pg:equery(tag_analysis_pool, Q2, [Word, Rels]),
            io:format("~p~n", [Word]),
            read_line(FileDev)
    end.
