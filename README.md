# desk

## What is this?
Assignment for Desk. Nuff said.

## Technology choices

Ruby 2.1 and Rails 4.1 are natural choices as latest stable versions of
language/framework.

Faraday is my library of choice for client http work. It has been around
for quite some time, it is stable, has nice pluggable architecture and
allows to wrap many popular http libraries, providing them all with
unified interface. Switching from net/http to typhoeus is effortless if
app is using Faraday. It also provides good support for functional
testing.

Some premade Faraday middleware was used as is, while some was written
for the project to be a best fit.

## Challenges

Scope of the project is just too large. Provided that there is only a
week to complete it, and one still has a day job and family, there is so
only so much time to spend on it. Decision was made to do half a job
instead of half-assed job, and UI part of it was left out. Good UI takes
effort, time and knowledge, and I do not have much of those currently
(yes, those days I am predominantly a back-end developer).

## Inclusions / Exclusions
Client API library was implemented for interfacing with Desk.com API's.
ETag-based caching was included. So was error handling, retry on errors,
automatic wait & retry on hitting rate limit and production level
logging.
Paging was excluded out of scope of this assignment (it takes knowledge
of intended API usage to decide on how to best handle paging, and it was
another opportunity to pare down scope).
Implementing another, aggressive level of (backup) caching was also
left out - it would have a benefit of keeping app (mostly) working
even when connection to Desk.com is disrupted; it would be a very
interesting excercise.

## Surpises

Deleting a label using Desk.com API does not really delete it, but
just hides it from view completely. Trying to create it later again
results in reactivation of label, but with all its associated data gone
(including 'active' flag no longer being set to true). Quite surprising behavior,
given that create, and create-delete-create result in a very different
outcomes.

## Discoveries

Finally figured out a nasty bug in Faraday::Retry middleware that
prevents it from successfully retrying requests in some scenarios.
Pull request with fix submitted: https://github.com/lostisland/faraday/pull/429
