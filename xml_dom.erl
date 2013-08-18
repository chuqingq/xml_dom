-module(xml_dom).

-export([simple_form/1, simple_form/2]).

-include_lib("xmerl/include/xmerl.hrl").

-type elem() :: {Name::string(), Attrs::[{string(), string()}], string() | [elem()]}.

%% API

simple_form(File) when is_list(File) ->
    simple_form(File, []).

-spec simple_form(File::string(), Opts::[tuple()]) -> {ok, elem()} | {error, Reason::any()}.
simple_form(File, Opts) when is_list(File) andalso is_list(Opts) ->    
    try xmerl_scan:file(File, Opts) of
        {E = #xmlElement{}, _Tail} ->
            parse_element(E);
        Error -> Error
    catch _E:Pattern -> {error, Pattern}
    end.

%% Internal functions

parse_element(#xmlElement{name = Name, attributes = Attrs, content = Content}) ->
    {atom_to_list(Name), [parse_attribute(A) || A <- Attrs], parse_children(Content)}.

parse_text(#xmlText{value = Value}) -> Value.

parse_attribute(#xmlAttribute{name = Name, value = Value}) ->
    {atom_to_list(Name), strip(Value)}.

parse_children(Es) ->
    case [parse_element(E) || E = #xmlElement{} <- Es] of
        [] ->
            Es1 = [parse_text(E) || E <- Es],
            strip(lists:concat(Es1));
        Es1 -> Es1
    end.

strip(Text) when is_list(Text) ->
    %% TODO
    Text.

%% TODO Tests
