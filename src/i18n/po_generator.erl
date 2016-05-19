%% Author: dave
%% Created: Mar 1, 2010
%% Description: Generates po files from dets tables, based on erlang gettext impl
-module(po_generator).
-define(ENDCOL, 72).
%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([generate_file/3]).

%%
%% API Functions
%%
-define(LANG_DIR, "lang").
-define(POFILE, "gettext.po").
generate_file(Lang,Items, Fuzzy) ->
    Gettext_App_Name = "tmp",
    GtxtDir = ".",
    io:format("Opening po file"),
    DefDir = filename:join([GtxtDir, ?LANG_DIR, Gettext_App_Name, Lang]),
    Fname = filename:join([DefDir, ?POFILE]),
    filelib:ensure_dir(Fname),
    {ok,Fd} = file:open(Fname, [write]),
    put(fd,Fd),

    gettext_compile:write_header(),
    io:format("Writing entries~n"),
    write_entries(Items),
    io:format("Writing fuzzy entries~n"),
    write_fuzzy_entries(Fuzzy),
    gettext_compile:close_file().

%%
%% Local Functions
%%
write_entries(Items)->
    Fd = get(fd),
    F = fun({Id,Translation,Finfo}) ->
                ok = file:write(Fd, "msgid \"\"\n"),
                gettext_compile:write_pretty(Id, Fd),
                ok = file:write(Fd, "msgstr \"\"\n"),
                gettext_compile:write_pretty(Translation, Fd)
        end,
    lists:foreach(F, Items).

write_fuzzy_entries(Items) ->
    Fd = get(fd),
    ok = file:write(Fd, "\n"),
    F = fun({Id,Translation,_}) ->
                ok = file:write(Fd, "#, fuzzy\n"),
                ok = file:write(Fd, "msgid \"\"\n"),
                gettext_compile:write_pretty(Id, Fd),
                ok = file:write(Fd, "msgstr \"\"\n"),
                gettext_compile:write_pretty(Translation, Fd),
                ok = file:write(Fd, "\n")
        end,
    lists:foreach(F, Items).
