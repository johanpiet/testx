module.exports =
  'go to': (args) ->
    browser.get args.url
  'go forward': ->
    browser.navigate().forward()
  'go back': ->
    browser.navigate().back()
  'refresh page': ->
    browser.navigate().refresh()
  'clear local storage': ->
    browser.executeScript 'window.localStorage.clear();'
  'delete cookies': ->
    browser.manage().deleteAllCookies()