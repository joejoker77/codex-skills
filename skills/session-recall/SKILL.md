# Skill: session-recall

Find what was already said instead of asking the person to say it again.

## Trigger
"as we agreed", "like last time", "the address I gave you", "что мы решили", "как в прошлый раз"
— any reference to something settled earlier that is not in front of you.

## Steps

1. Look at what is already in this conversation and in your notes first. If the answer is there,
   use it and say where it came from.
2. `session-search "<two or three distinctive words>"` — quote a phrase to search it as a phrase.
   Characters like `.` `-` `:` are operators, so quote them when they are literal.
3. Narrow with `--since YYYY-MM-DD` when you know roughly when, and `--limit N` for more hits.
4. Read around the hit before relying on it: a single line can be the question rather than the
   answer, or a plan that was later changed.
5. Only then ask — and say what you already looked at, so the person is not retracing your steps.

## Why

Being made to repeat something to a tool built to remember is the fastest way to spend
someone's patience. The search is cheap; the second telling is not.
