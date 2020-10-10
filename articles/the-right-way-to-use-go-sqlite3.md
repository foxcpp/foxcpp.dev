---
template: article
title: The right way to use go-sqlite3
description: Why go-sqlite3 is spitting out 'database is locked' errors and what to do about it.
date: 2020-10-10
---

SQLite is a wonderful piece of software and it is completely meaningful to use
it in a project written in Go even though SQLite itself is in C.  Though people
has been hitting lots of issues with it, mostly "database is locked" error that
seems to appear out of nowhere.

First of all, SQLite allows concurrent readers but only a single writer.
Unlike most places where you may encounter some sort of synchronization SQLite
does not wait for the write lock to become available - instead it just returns
an error, letting the caller deal with it. This is why you are getting
"database is locked" errors.

It is actually possible to make SQLite wait for the lock for limited time by
specifying a [busy_timeout] PRAGMA value. However, since database/sql can
and will create multiple "connections" to DB it is wrong to apply it like this:
```go
db.Exec("PRAGMA busy_timeout = 10000;")
```
This will get applied only to a single random connection that may or may not
be used later and you will still get "database is locked" errors.

go-sqlite3 supprots specifying some PRAGMA values via DSN, this is how you should
set busy_timeout: 
```go
sql.Open("sqlite3", "file:whatever.db?_busy_timeout=10000")
```

However, note that it will not make SQLite magically be able to handle
concurrent writes - you can still get "database is locked" errors from time to
time. There are more things you can do (and should not do) to improve the
situation, however:

1. Switch journaling mode to WAL.

By default, SQLite uses "legacy" rollback journal mode to ensure transaction
ACID properties. There is an alternative mode based on write-ahead logging.
You can read more about it in [SQLite docs][wal] but in practice it is almost
always better than rollback journal mode, so, start using it:

```go
sql.Open("sqlite3", "file:whatever.db?_busy_timeout=10000&_journal=WAL")
```

Also it is likely a good idea to set `PRAGMA synchronous = NORMAL`:
```go
sql.Open("sqlite3", "file:whatever.db?_busy_timeout=10000&_journal=WAL&_sync=NORMAL")
```
More details [here][sync].

2. Do not restrict connection count to 1.

This is a very bad suggestion that is still in go-sqlite3 README for some reason. 
Effectively it removes SQLite's ability of handling concurrent read operations
by wrapping all DB access with an exclusive mutex.

3. ... but enable shared cache.

So we allow database/sql to create multiple "connections". In this situation
SQLite3 will benefit from sharing page cache across connections:

```go
sql.Open("sqlite3", "file:whatever.db?_busy_timeout=10000&_journal=WAL&_sync=NORMAL&cache=shared")
```

Given that you do all of these, you should get SQLite perfomance to the best
possible level therefore getting "database is locked" much much less. And of course
it is a good idea to not do any expensive operations (such as unrelated I/O) while
transaction is active.

If you still keep getting the same error out of nowhere when not doing concurrent
writes - make sure you commit/rollback all sql.Tx objects and close all sql.Rows
objects. 

[busy_timeout]: https://sqlite.org/pragma.html#pragma_busy_timeout
[wal]: https://www.sqlite.org/wal.html
[sync]: https://www.sqlite.org/pragma.html#pragma_synchronous
