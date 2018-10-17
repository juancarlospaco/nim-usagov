## Code.Gov MultiSync API Client for Nim
## =====================================
##
## Code.gov is on a mission to become the primary platform where America shares code.
## Code.gov API is a public API. Data from the API will be delivered in JSON.
## **Get data & code from NASA, LIGO, Fermilab, MIT, Harvard, & more on seconds!.**
##
## About This client
## -----------------
##
## This Client is Async & Sync at the same time.
## CrossPlatform. CrossArchitecture. 0 Dependency. 1 File. ~250Kilobytes Compiled.
## Can run itself for an example. Proxy, IPv6, SSL & Timeout Support. Tiny RAM use.
## Needs 1 Free API Key. Self Rate Limited at 5000 Calls/Day. Self-Documented.
##
## .. image:: https://raw.githubusercontent.com/GSA/code-gov/master/images/community.png
import asyncdispatch, httpclient, strformat, json, times

const usagov_api_url* = "https://api.code.gov/" ## Base API URL for all USA Code.
var countero, dayOfYear: int16  # Counter & marker to rate limit 5000 calls/day.

type
  USAGovBase*[HttpType] = object  ## Base Object for https://developers.code.gov
    proxy*: Proxy  ## Network IPv4 / IPv6 Proxy support, Proxy type.
    timeout*: int8  ## Timeout Seconds for API Calls, int8 type.
    apikey*: string ## Code.Gov API Key, get Free at http://api.data.gov/signup
  USAGov* = USAGovBase[HttpClient]           ## USA Code.Gov API  Sync Client.
  AsyncUSAGov* = USAGovBase[AsyncHttpClient] ## USA Code.Gov API Async Client.

proc apicall(this: USAGov | AsyncUSAGov, api_url: string): Future[JsonNode] {.multisync.} =
  assert this.apikey.len == 40 or this.apikey == "DEMO_KEY", "API Key must be String of 40 Chars"
  inc countero
  let hoy = now().year.getDaysInYear.int16
  if dayOfYear == 0.int16:  # Day of the Year not set, set it to today.
    dayOfYear = hoy
  if dayOfYear != hoy:     # Day of Year changed, reset counter to zero.
    dayOfYear = hoy
    countero = 0.int16
  if countero >= 5000:     # Counter hit 5000 today, throw exception for good.
    raise newException(ValueError, "API Rate Limit hit at 5,000 Calls / Day.")
  let response =
     when this is AsyncUSAGov:
       await newAsyncHttpClient(proxy = when declared(this.proxy): this.proxy else: nil).get(api_url)
     else:
       newHttpClient(timeout=this.timeout * 1000, proxy = when declared(this.proxy): this.proxy else: nil ).get(api_url)
  result = parseJson(await response.body)

proc repos*(this: USAGov | AsyncUSAGov, q: string, size: int8 = 10, fr0m: int8 = 0,
            agency_name="", agency_acronym="", agency_website="", status="", vcs="",
            name="", organization="", tags="", languages="", contact_name="",
            contact_email="", permissions_licenses_name="", permissions_usageType= [""],
            laborHours=0, date_created="", date_lastModified=""): Future[JsonNode] {.multisync.} =
  ## Get list of repositories indexed by Code.gov.
  let
    a = if agency_name != "": fmt"&agency_name={agency_name}" else: ""
    b = if agency_acronym != "": fmt"&agency_acronym={agency_acronym}" else: ""
    c = if agency_website != "": fmt"&agency_website={agency_website}" else: ""
    d = if status != "": fmt"&status={status}" else: ""
    e = if vcs != "": fmt"&vcs={vcs}" else: ""
    f = if name != "": fmt"&name={name}" else: ""
    g = if tags != "": fmt"&tags={tags}" else: ""
    h = if languages != "": fmt"&languages={languages}" else: ""
    i = if contact_name != "": fmt"&contact_name={contact_name}" else: ""
    j = if contact_email != "": fmt"&contact_email={contact_email}" else: ""
    k = if permissions_licenses_name != "": fmt"&permissions_licenses_name={permissions_licenses_name}" else: ""
    l = if permissions_usageType != [""]: fmt"&permissions_usageType={permissions_usageType}" else: ""
    m = if laborHours != 0: fmt"&laborHours={laborHours}" else: ""
    n = if date_created != "": fmt"&date_created={date_created}" else: ""
    o = if date_lastModified != "": fmt"&date_lastModified={date_lastModified}" else: ""
  result = await this.apicall(
    fmt"{usagov_api_url}repos?api_key={this.apikey}&size={size}&from={fr0m}&q={q}" &
    fmt"{a}{b}{c}{d}{e}{f}{g}{h}{i}{j}{k}{l}{m}{n}{o}")

proc repos_repoid*(this: USAGov | AsyncUSAGov, repoid: string): Future[JsonNode] {.multisync.} =
  ## Gets the information of a specific repository index with the passed repoId.
  result = await this.apicall(fmt"{usagov_api_url}repos/{repoid}?api_key={this.apikey}")

proc terms*(this: USAGov | AsyncUSAGov, term, term_type: string,
            size: int8 = 10, fr0m: int8 = 0): Future[JsonNode] {.multisync.} =
  ## Get a list of terms that were extracted from the repositories indexed.
  result = await this.apicall(
    fmt"{usagov_api_url}terms?api_key={this.apikey}&term={term}" &
    fmt"&term_type={term_type}&size={size}&from={fr0m}")

proc agencies*(this: USAGov | AsyncUSAGov, size: int8 = 10, fr0m: int8 = 0): Future[JsonNode] {.multisync.} =
  ## Get a list of all agencies.
  result = await this.apicall(fmt"{usagov_api_url}agencies?api_key={this.apikey}&size={size}&from={fr0m}")

proc languages*(this: USAGov | AsyncUSAGov, size: int8 = 10, fr0m: int8 = 0): Future[JsonNode] {.multisync.} =
  ## Returns a list of programming languages used in the indexed code inventory.
  result = await this.apicall(fmt"{usagov_api_url}languages?api_key={this.apikey}&size={size}&from={fr0m}")

proc repo*(this: USAGov | AsyncUSAGov): Future[JsonNode] {.multisync.} =
  ## Get the JSON schema for a repo.
  result = await this.apicall(fmt"{usagov_api_url}repos.json?api_key={this.apikey}")

proc status*(this: USAGov | AsyncUSAGov): Future[JsonNode] {.multisync.} =
  ## Get a list of agencies with their Federal Source Code Policy compliance status.
  result = await this.apicall(fmt"{usagov_api_url}status.json?api_key={this.apikey}")

proc status_fetched*(this: USAGov | AsyncUSAGov, agencyName: string): Future[JsonNode] {.multisync.} =
  ## Lists out all repositories that have been indexed for a given agency.
  result = await this.apicall(fmt"{usagov_api_url}status/{agencyName}/fetched?api_key={this.apikey}")

proc status_discovered*(this: USAGov | AsyncUSAGov, agencyName: string): Future[JsonNode] {.multisync.} =
  ## Get a list of repos by agency.
  result = await this.apicall(fmt"{usagov_api_url}status/{agencyName}/discovered?api_key={this.apikey}")

proc version*(this: USAGov | AsyncUSAGov): Future[JsonNode] {.multisync.} =
  ## Get the version of the API.
  result = await this.apicall(fmt"{usagov_api_url}version?api_key={this.apikey}")


when is_main_module:    # Example code.
  # Sync client.
  let codegov_client = USAGov(timeout: 9, apikey: "DEMO_KEY") # "DEMO_KEY" can fail.
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
