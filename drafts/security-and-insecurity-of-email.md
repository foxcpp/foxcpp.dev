---
template: article
title: Security and insecurity of e-mail
---

**This is article draft and not a final version. You can submit suggestions on
https://github.com/foxcpp/foxcpp.dev.**

## (Un)Trustworthy SMTP

SMTP was created at the dawn of Internet when nobody considered any security
issues. In fact, [RFC 821] does not use any of the following words:
"authentication", "security", "privacy", "integrity". **Not a single time.**

Now almost 40 years passed since RFC 821 publication, something must have
changed. _Right?_ Not that much, the trust model of is still defined on
per-server basis. It is not about users trusting users. It is about servers
trusting other servers and users hoping servers are good. SMTP by itself,
however, just assumes that every actor is good and does not provide any
security.  Several mechanisms were developed to improve that. They, however,
are still limited to the original trust model. That is, they authenticate one
server to another, not even the whole chain if more than 2 servers participate
in transmission (in the most basic case there are only 2 parties and 2 servers
involved, but that might be different for many othese scenarios). 

To provide such end-to-end authentication additional protocols must be used on
top of e-mail stack, such as S/MIME or PGP. Even then, there is a big amount of
metadata transferred in plaintext. RFC 5322 header section is full of
interesting things including recipient, sender addresses and timestamps added
by each server. It is often as precious as the contents of the message
themselves. ["We kill people based on metadata"][wkpbm], remember?.

Even without RFC 5322, there is at least SMTP envelope that includes recipient
and sender address. [Some systems][ricochet] manage to deliver messages without
knowing who is talking to whom, possibly using transient or meaningless
identifiers. This is not possible in e-mail where these familar strings with
`@` in the middle are central to the protocol.

So, once again. E-mail requires you to trust the server you use. System
administrator with malicious intent can easily read all your messages no matter
what.

## Fragile server-server encryption

So, okay, we understand limitations of e-mail stack security. Lets assume we
are in the happy utopia where the half of the world is not using a [single
e-mail service](https://gmail.com) and users generally trust their server.

Is e-mail good now? Not really. Remember these 40 years I mentioned earlier?
(Almost) all security mechanisms introduced stay backward-compatible with the
pure ~~naked~~ [RFC 821]. That means it is possible to nullify all security
enhancements offered. This is necessary, however, since otherwise nobody would
adopt these enhancements altogether. And in fact, they bring some value.
This is called Opporunistic Security aka "[Some Protection Most of the
Time][RFC 7435]".

It is [relatively trivial][eff-starttls-downgrade] to strip magic STARTTLS line
from ESMTP negotiation and just listen to your neighbor e-mail server sending
its precious messages in plaintext. MTA-STS and DANE were created to make this
impossible, but they rely on DNS to provide out-of-band "signal" to enable
mandatory TLS. Therefore, DNSSEC is criticial for e-mail security. However, as
of 2017. DNSSEC deployment remains low or just broken (see [imc17], [sec17]).
This compromises remaining bits of e-mail security. 

There is a bright hope that EFF will succeed with its [STARTTLS
Everywhere][starttls-everywhere] effort that aims to compensate for poor DNSSEC
deployment. And DNSSEC deployment actually grows. So, perhaps in several years
everything will be in a better shape. But not now, just not now.

## "Encrypted" mail services & web clients

TODO

## Archival vs Perfect Forward Secrecy

TODO

## On Pretty Good Privacy (PGP)

TODO 

**TL;DR** E-mail was never designed to provide end-to-end privacy and/or
integrity. Several design decisions at various levels conflict with the goal to
provide maximum security.

[RFC 821]: https://tools.ietf.org/html/rfc821
[wkpbm]: https://www.nybooks.com/daily/2014/05/10/we-kill-people-based-metadata/
[ricochet]: https://ricochet.im
[RFC 7435]: https://tools.ietf.org/html/rfc7435
[imc17]: https://securepki.org/imc17.html
[sec17]: https://securepki.org/sec17.html
[eff-starttls-downgrade]: https://www.eff.org/deeplinks/2014/11/starttls-downgrade-attacks
[starttls-everywhere]: https://starttls-everywhere.org
