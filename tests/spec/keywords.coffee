describe 'Keyword', ->
  it 'that requrie basic navigation should work', ->
    testx.run 'tests/scripts/cookies.testx'
    testx.run 'tests/scripts/navigate.testx'
  it 'wait should work', ->
    testx.run 'tests/scripts/wait.testx',
      match: 'testxio'
