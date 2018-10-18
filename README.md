# Nim-USAGov

- USA Code.Gov MultiSync API Client for Nim. Get data &amp; code from NASA, LIGO, Fermilab &amp; more on seconds!


![Code.Gov](https://raw.githubusercontent.com/GSA/code-gov/master/images/community.png "Code.Gov Open Source Code")


Code.gov is on a mission to become the primary platform where America shares code.

Code.gov API is a public API. Data from the API will be delivered in JSON.

This Client is Async & Sync at the same time. CrossPlatform. CrossArchitecture. 0 Dependency. 1 File. ~250Kilobytes Compiled. Can run itself for an example. Proxy, IPv6, SSL & Timeout Support. Tiny RAM use. Self Rate Limited at 5000 Calls/Day. Self-Documented.


# Install

```
nimble install usagov
```


# Use

```nim
import usagov

# Sync client.
let codegov_client = USAGov(timeout: 9, apikey: "DEMO_KEY")
echo $codegov_client.repos(q="python")
echo $codegov_client.agencies()
echo $codegov_client.languages()
echo $codegov_client.repo()
echo $codegov_client.status()
echo $codegov_client.version()

# Async client.
proc asyncodegov {.async.} =
  let
    async_codegov_client = AsyncUSAGov(timeout: 9, apikey: "DEMO_KEY")
    async_response = await async_codegov_client.version()
  echo $async_response

wait_for asyncodegov()

# Check the Docs for more API Calls...
```


# API

- [Check the Code.Gov Docs](https://api.code.gov), the Lib is a 1:1 copy of the official Docs.
- This Library uses API Version from Year `2018`.
- All procs should return a JSON Object `JsonNode`.
- The order of the procs follows the order on the Code.Gov Docs.
- The naming of the procs follows the naming on the Code.Gov Docs.
- The errors on the procs follows the errors on the Code.Gov Docs.
- The API Rate Limit follows the limits on the Code.Gov Docs.
- All API Calls use HTTP `GET`.
- The `timeout` argument is on Seconds.
- For Proxy support define a `proxy` of `Proxy` type.
- No OS-specific code, so it should work on Linux, Windows, Mac, etc.
- Run `nim doc usagov.nim` to generate the self-Documentation.
- Run the module itself for an Example.


# Screenshots

![Code.Gov](https://raw.githubusercontent.com/juancarlospaco/nim-usagov/master/temp.png "Code.Gov Open Source Code")


# Support

- All Code.Gov API is supported, except fetching static HTML pages.


# FAQ

- I dont live in US why should I care?.

Lots of Scientific/Educational/Medical institutions have base on US.
You can explore and hack on code from NASA, LIGO, among others.
All Public funded code should be Open Source.

- This works with Asynchronous code ?.

Yes.

- This works with Synchronous code ?.

Yes.

- This works without SSL ?.

No.

- This requires API Key or Login ?.

Yes. 1 Free API Key. Easy to obtain.

- This requires Credit Card or Payments ?.

No.

- Can I use the Code.Gov data ?.

Yes. All source code is Open source.


# Requisites

- None.

