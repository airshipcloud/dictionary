create table "tags" (
    "id" bigint not null,
    "name" character varying(255) not null);

create table "tagged" (
    "tag_id" bigint not null,
    "agent_id" bigint not null,
    "object_id" bigint not null);

create unique index "tags_name_uq" on "tags" ("name");
create unique index "tags_id_uq" on "tags" ("id");

create unique index "tagged_uq" on "tagged" ("tag_id", "agent_id", "object_id");

create table "synonyms"("id" bigint, "tag_id" bigint);
create unique index "synonyms_uq" on "synonyms"("id", "tag_id");
create index "synonyms_ix" on "synonyms"("id");

create or replace function "hash_id"(v text)
    returns bigint as
    $$
    declare
        "_hash" text;
        "_id" bigint;
    begin
        "_hash" := md5(v);
        execute 'select x''' || substring("_hash" from 1 for 13) || '''::bigint#x''' || substring("_hash" from 14 for 13) || '''::bigint#x''' || substring("_hash" from 27 for 6) || '''::bigint' into "_id";
        return "_id";
    end;
    $$
    language plpgsql;

create table "wordnet_synonyms"("word" text, "synonym" text, "word_ts" text, "synonym_id" bigint);
create unique index "wordnet_synonyms_uq" on "wordnet_synonyms"("word", "synonym");
create index "wordnet_synonyms_word_ts_ix" on "wordnet_synonyms"("word_ts");

create or replace function "insert_wordnet_synonyms"("_word" text, "_synonyms" text[])
    returns void as
    $$
    declare
        "_synonym" text;
    begin
        foreach "_synonym" in array "_synonyms" loop
            begin
                insert into "wordnet_synonyms"("word","synonym","word_ts","synonym_id") values("_word","_synonym",to_tsvector("_word")::text,hash_id(to_tsvector("_synonym")::text));
            exception when unique_violation then
            end;
        end loop;
    end;
    $$
    language plpgsql;

create table "wordnet_generics"("word" text, "generic" text, "word_ts" text, "generic_id" bigint);
create unique index "wordnet_generics_uq" on "wordnet_generics"("word", "generic");
create index "wordnet_generics_word_ts_ix" on "wordnet_generics"("word_ts");

create or replace function "insert_wordnet_generics"("_word" text, "_generics" text[])
    returns void as
    $$
    declare
        "_generic" text;
    begin
        foreach "_generic" in array "_generics" loop
            begin
                insert into "wordnet_generics"("word","generic","word_ts","generic_id") values("_word","_generic",to_tsvector("_word")::text,hash_id(to_tsvector("_generic")::text));
            exception when unique_violation then
            end;
        end loop;
    end;
    $$
    language plpgsql;

create table "wordnet_related"("word" text, "related" text, "word_ts" text, "related_id" bigint);
create unique index "wordnet_related_uq" on "wordnet_related"("word", "related");
create index "wordnet_related_word_ts_ix" on "wordnet_related"("word_ts");

create or replace function "insert_wordnet_relateds"("_word" text, "_relateds" text[])
    returns void as
    $$
    declare
        "_related" text;
    begin
        foreach "_related" in array "_relateds" loop
            begin
                insert into "wordnet_related"("word","related","word_ts","related_id") values("_word","_related",to_tsvector("_word")::text,hash_id(to_tsvector("_related")::text));
            exception when unique_violation then
            end;
        end loop;
    end;
    $$
    language plpgsql;
