---
template: article
title: Security and insecurity of e-mail
description: Rant about emails messy threat model. What SPF/DKIM/etc do and do not. Why we can do better than PGP.
date: 2020-06-23
---

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
involved, but that might be different for many other scenarios). 

To provide such end-to-end authentication additional protocols must be used on
top of e-mail stack, such as S/MIME or PGP. But a rare person uses PGP on daily
basis, right? UI of implementations is unintuitive, key management is hard and
so on. Even then, there is a big amount of metadata transferred in plaintext.
RFC 5322 header section is full of interesting things including recipient,
sender addresses and timestamps added by each server. It is often as precious
as the contents of the message themselves. 
["We kill people based on metadata"][wkpbm], remember?.

Even without RFC 5322, there is at least SMTP envelope that includes recipient
and sender address. [Some systems][ricochet] manage to deliver messages without
knowing who is talking to whom, possibly using transient or meaningless
identifiers. This is not possible in e-mail where these familar strings with
`@` in the middle are central to the protocol.

To put that all in a perspective: Lets say you are a whistleblower and you want
to tell press about terrible things happening in your company. You use OpenPGP.
After all, its [web site](https://openpgp.org) fills you with sense of
confidence and security. You send a message to the journalist using work e-mail
system. What might go wrong? PGP is secure! Well... You are doomed. Admin of
that e-mail system knows what you were doing. That is enough.

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

All that sounds pretty scary. But [ProtonMail] must save me. Their landing page 
proudly says "Secure Email Based in Switzerland".

While I appreciate that they actually do [pretty well][mailsec-check] in terms
of e-mail security:
```
$ ./mailsec-check protonmail.com
-- Source forgery protection
[+] DKIM: 	 _domainkey subdomain present; DNSSEC-signed; 
[+] SPF: 	 present; strict; DNSSEC-signed; 
[+] DMARC: 	 present; strict; DNSSEC-signed; 

-- TLS enforcement
[+] MTA-STS: 	 enforced; all MXs match policy; 
[+] DANE: 	 present for all MXs; DNSSEC-signed; no validity check done; 

-- DNS consistency
[+] FCrDNS: 	 all MXs have forward-confirmed rDNS
[+] DNSSEC: 	 A/AAAA and MX records are signed;
```
But efforts of Protonmail developers cannot make the underlying protocol secure.
SMTP is still SMTP. Messages cannot stay magically encrypted if they exit the
Protonmail servers. 

Two important details to keep in mind even if messages do not leave ProtonMail
servers. First, ProtonMail still knows who is talking to whom. As shown
eariler, this is already enough to cause doom in many cases. Second, ProtonMail
is a proprietary platform without open API and the only clients available are
provided developed and maintained by ProtonMail people. Nothing is preventing
them from inserting a backdoor to push unencrypted messages somewhere else **at
any time**. In case of web client most people will probably use it will be
completely invisible, not even a prompt like "new version of client is
downloaded". Just your messages will be silently sent unencrypted somewhere
else.

That is, ProtonMail is not getting anywhere better than a regular server with 
encrypted storage.

Of course ProtonMail is just one example, there are [other][tutanota]
[similar][startmail] services.

No matter what brand is your favorite. The trust model of SMTP will keep
haunting you. There is not magic pixie here that makes e-mail secure.

## Archival, Perfect Forward Secrecy and Not Pretty Good Privacy (PGP)

Now that is depressing, right? Our only hope left is PGP. Unfortunately, it is
not a new technology and it definitely does not account for all research that
was made in cryptography the last three decades.

Numerious problems were identitied in the OpenPGP standard, most of them were
patched or otherwise workarounded. There were severe vulnerabilities in
implementations like EFAIL but they do not affect the protocol itself So, in
general, an up-to-date PGP implementation (e.g. [GnuPG][gpg]) should stay
secure. Except that it is not more secure than it was in 90s. We can do much
better today. 

PGP fundamentally was built with e-mail in mind. Notably, it has to provide a
way to encrypt the message at any time in future since e-mail messages are
often archived for rather long periods of time. This conflicts with the goal to
provide the [Perfect Forward Secrecy][pfs] property. That is, even if long-term
keys are compromised, previous converations stay secret.

<hr>

**TL;DR** E-mail was never designed to provide end-to-end privacy and/or
integrity. Several design decisions at various levels conflict with the goal to
provide maximum security.

## What do I do?

E-mail is not going anywhere in the next decade. It is too deeply integrated in
the worldwide ecosystem. From my experience, you live a life without having a
phone number, without having the phone itself but you cannot live in the modern
world without a e-mail address. It is used for everything.

Many things could be improved and they will be get improved eventually. I am
not aware of any effort to replace what was initially known to be Internet
Mail while providing the same features. A paradigm shift is needed to achieve
better security.

[RFC 821]: https://tools.ietf.org/html/rfc821
[wkpbm]: https://www.nybooks.com/daily/2014/05/10/we-kill-people-based-metadata/
[ricochet]: https://ricochet.im
[RFC 7435]: https://tools.ietf.org/html/rfc7435
[imc17]: https://securepki.org/imc17.html
[sec17]: https://securepki.org/sec17.html
[eff-starttls-downgrade]: https://www.eff.org/deeplinks/2014/11/starttls-downgrade-attacks
[starttls-everywhere]: https://starttls-everywhere.org
[ProtonMail]: https://protonmail.com
[mailsec-check]: https://github.com/foxcpp/mailsec-check
[tutanota]: https://tutanota.com
[startmail]: https://startmail.com
[gpg]: https://gnupg.org
[pfs]: https://en.wikipedia.org/wiki/Forward_secrecy
