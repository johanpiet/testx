testx
=====

A library for executing MS Excel based, keyword driven tests with Protractor.

- [Migrating to testx 1.x](#migrating-to-testx-1.x)
- [How does it work](#how-does-it-work)
- [Prerequisites](#prerequisites)
- [API](#api)
- [Installation](#installation)
- [Run](#run)
- [Configuration](#configuration)
- [Core keywords](#core-keywords)
- [Additional keyword packages](#additional-keyword-packages)

## Migrating to testx 1.x
There are a few breaking changes in **testx 1.0** as compared to **testx 0.x**, but you should only need to change your configuration file and not your tests.

### Reporting
Reporting is no longer done by **testx**. Instead you should take care of it yourself. I've pulled out (and refactored a bit) the old reporting code into a separate package [testx-ictu-reporter](https://www.npmjs.com/package/testx-ictu-reporter).

This lead to the removal of the onPrepare and onComplete methods from the **testx** API. These methods were only adding the jasmine reporters and sending test results, respectively, so there is no need for them anymore. You should just remove the calls to them from your config file.

### Adding objects, keywords and functions
There is a slight change in the **testx** object.

Instead of

	testx.addObjects(require './objects')
	testx.addObjects 'objects/objects.csv'
	testx.addKeywords(require './keywords')
	testx.addKeywords(require 'testx-pdf-keywords')
	testx.addFunctions(require './my-functions')

You will now do

	testx.objects.add(require './objects')
	testx.objects.add 'objects/objects.csv'
	testx.keywords.add(require './keywords')
	testx.keywords.add(require 'testx-pdf-keywords')
	testx.functions.add(require './my-functions')

## How does it work
**testx** aims to make web application testing easier by using keyword driven testing.

**testx** uses MS Excel sheets as a platform for writing tests.
Essentially you write your tests in MS Excel, utilizing the computational power of MS Excel.
This will free you from having to implement all the things like generating random data, referring to values in other test steps. formatting dates, etc.

It is possible to use **testx** without MS Excel as well, but then it looses a lot of its usefulness.
Of course if you don't want to shell out for MS Excel you can use any of the numerous copies like LibreOffice (OpenOffice) Calc, etc.

### Test structure
The tests consist of *steps*. Each step consists of a *keyword* and *arguments*.

The keyword is an action or a check (or both, can be anything really).
The arguments consist of a name and a value. Both the name and the value can be literals, context references or object keys.

In MS Excel a test looks something like that (taken from the sample project):

|                   | url         |             |
| -------------     | ----------- | ----------- |
| **go to**         | /           |             |
|                   | **query-input** | **search-btn**  |
| **set**           | new york    |             |
|                   | **object**  | **timeout** |
| **wait to appear**| result-link | 4000        |
|                   | **result-link** |         |
| **check matches** | New York    |            ||

#### Keywords
You can think of the step as the action you want to perform using the provided arguments.
In this context the keyword is the action.

#### Objects
The other key component at work here is the **object map**.

It is a dictionary of *object keys* - the stuff you put in your scripts to identify objects on the screen - and *object locators*.

Object locators are simple objects consisting of *locator* and *value*.

The locator can be any of the supported protractor element selector types, i.e. *id*, *css*, *xpath*, etc.

The value is the actual value of the selector - "element-id", ".hidden.button", "//input[@type='button']", etc.

Clients (test projects) use the **addObjects** method to add to the object map. For example (from the sample project *conf.coffee*)

	testx = require 'testx'
	onPrepare: ->
		testx.objects.add require('./objects')

And in *objects/index.coffee* you'll have something like:

	module.exports =
	  "query-input":
	    locator: "css"
	    value: "input[name='q']"
	  "search-btn":
	    locator: "css"
	    value: "button[name='btnG']"
	  "result-link":
	    locator: "css"
	    value: "li.g a"

Objects can also be read from CSV file. The file looks like this:

	query-input,css,"input[name='q']"
	search-btn,css,"button[name='btnG']"
	result-link,css,"li.g a"


As of **testx 0.7.0** objects ini the object map can be functions as well. This gives you the ability to parameterize object. This is easiest to explain with an example. Let's say you have this object definition:

	module.exports =
	  "query-input": (attr, val) ->
	    locator: "css"
	    value: "input[#{attr}='#{val}']"

It can then be used to set an *input* element with arbitrary name like so (in your Excel sheet):

|                 | query-input('name','q') |
| -------------   | ----------- |
| **set**         | something  ||

In the example above "name" and "q" will be passed to the object function as the *attr* and *val* parameters and the return value of the function will be used to locate the element. In this example the resulting locator will be "input[name='q']". The only requirement is that the parameters you pass have to be put in quotes. If you want to have a quote (') as part of a parameter you need to escape it using back slash (\\).

## API
TBD

## Prerequisites

**testx** will only work in protractor based projects. Supported protractor versions are 2.0.0 and up.

## Installation

Create a protractor project. For a sample project clone https://github.com/greyarch/testx-quickstart

Add this module to your project:

	npm install testx --save

This is already done in the sample project so there you only need to:

	npm install

## Run

From within the test project directory:

	protractor conf.coffee --baseUrl=http://google.com

## Configuration

To be able to use **testx** you'll need to services external to it.
One of them is essential - the xls(x) file to test converter,
and the other one, the reporting service is optional and sending data to it is switched off by default.

All **testx** configuration lives in your protractor configuration file under *params.testx*, for example (in coffeescript)

	params:
		testx:
      logScript: true
      actionTimeout: 4000

The available configuration options are
 - **logScript** - if *true* **testx** will log the test script (JSON) on the console before executing it; defaults to *false*.
 - **actionTimeout** - the timeout in milliseconds before a *get* or *set* action will fail, for example because the target element is not visible; defaults to 5000.

## Core keywords

**testx** comes with a simple set keywords that can be extended/overriden from the project.
See the **addKeywords** method for details.

Predefined keywords are:

*object key* - the object key as specified in the object map. The keyword is applied to this object (DOM element).
*value of the object* - this string value depends on the HTML type of the object. For example it will be the text of a label or the value attribute of an input element.

| Keyword                | Argument name | Argument value  | Description | Supports repeating arguments |
| ---------------------- | ------------- | --------------- |------------ | ---------------------------- |
| check equals           |               || Checks if the value of the object is exactly equal to the expected |            |
|                        | *object key*  | *expected*      || Yes |
| check matches          |               || Checks if the value of the object matches the expected regular expression ||
|                        | *object key*  | *expected regex* || Yes |
| clear local storage    |               |                 | Clears local storage. This keyword has no arguments. ||
| go back                |               |                 | Simulates pressing of the **Back** browser button |  |
| go forward             |               |                 | Simulates pressing of the **Fotrward** browser button |  |
| go to                  |               |                 | Navigate to a (relative to the --baseUrl) url |  |
|                        | url           | the url to navigate to || No |
| ignore synchronization |               |                 | Turn page synchronization for angular apps on or off ||
|                        | ignore        | true / false    || No |
| refresh page           |               |                 | Simulates pressing of the **Refresh** browser button |  |
| save                   |               |                 | Save the value of the object to the specified variable. The saved value can then be referred to by putting the variable name in double curly brackets like so *{{varname}}*. This can be done in both argument name and argument value ||
|                        | *object key*  | *variable name* || Yes |
| set                    ||| *sets* the value to the object; the exact action depends on the HTML type of the object. For example the value will be filled in an input box. If the value is empty string the action is **click** ||
|                        | *object key*  | *value*         || Yes |
| sleep                  ||| Pause the execution  of the script ||
|                        | seconds       | number of seconds to sleep  || No |
|                        | milliseconds  | number of milliseconds to sleep  || No |
| switch to              ||| switches the current action context to a different iframe or window |  |
|                        | title         | the title of the window you want to switch to| only one of *title* or *frame* can be specified | No |
|                        | frame         | *object key* identifying an iframe you want to switch to | only one of *title* or *frame* can be specified | No |
| wait to appear         ||| Wait for all the specified objects to appear and fail if this does not happen before the timeout. Argument names must be unique (for this instance of the keyword), but are otherwise ignored ||
|                        | *ignored*     | *object key*    || Yes |
|                        | timeout       | the timeout in milliseconds || No |
| wait to disappear      ||| Wait for all the specified objects to disappear and fail if this does not happen before the timeout. Argument names must be unique (for this instance of the keyword), but are otherwise ignored |            |
|                        | *ignorred*    | *object key*    || Yes |
|                        | timeout       | the timeout in milliseconds || No |
| run                    ||| Execute the test script in the specified file and sheet passing the remaining arguments as variables to that execution ||
|                        | file          | full file path  | Optional; Can be omitted, if the sheet is in the current file | No |
|                        | sheet         | the name of the excel sheet || No |
|                        | *var name*    | *var value*     || Yes |

## Additional keyword packages
| Npm package | Description |
| ----------- | ----------- |
|[testx-http-keywords](https://www.npmjs.com/package/testx-http-keywords)|Keywords to send simple http requests using the testx library.|
|[testx-pdf-keywords](https://www.npmjs.com/package/testx-pdf-keywords)|Keywords to test pdf files using the testx library.|
|[testx-pop3-keywords](https://www.npmjs.com/package/testx-pop3-keywords)|Keywords to test mailserver using pop3.|
|[testx-postgres-keywords](https://www.npmjs.com/package/testx-postgres-keywords)|Keywords to test postgres db.|
|[testx-soap-keywords](https://www.npmjs.com/package/testx-soap-keywords)|Extension for testx to test soap services.|
