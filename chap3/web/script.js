/*var createReactClass = require('create-react-class')

var Page = createReactClass({
  render(){
    return <JSXZ in="template" sel=".container">
      <Z sel=".item">Burgers</Z>,
      <Z sel=".price">50</Z>
    </JSXZ>
  }
})

ReactDOM.render(
  <Page/>,
  document.getElementById('root')
)*/

function test() {
  var test = React.createElement('p', {}, 'Hey I was created from React!')
  ReactDOM.render(
    test,
    document.getElementById('root')
  )
//  alert("Hello world")
}
