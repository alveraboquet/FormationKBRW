require('!!file-loader?name=[name].[ext]!./index.html')
var ReactDOM = require('react-dom')
var React = require("react")
var createReactClass = require('create-react-class')
require('./webflow/css/tuto.webflow.css');

var orders = [
  {remoteid: "000000189", custom: {customer: {full_name: "TOTO & CIE"}, billing_address: "Some where in the world"}, items: 2}, 
  {remoteid: "000000190", custom: {customer: {full_name: "Looney Toons"}, billing_address: "The Warner Bros Company"}, items: 3}, 
  {remoteid: "000000191", custom: {customer: {full_name: "Asterix & Obelix"}, billing_address: "Armorique"}, items: 29}, 
  {remoteid: "000000192", custom: {customer: {full_name: "Lucky Luke"}, billing_address: "A Cowboy doesn't have an address. Sorry"}, items: 0}, 
]

var Table = createReactClass( {
render(){
  return orders.map(order => (<JSXZ in="orders" sel=".t-row">
    <Z sel=".number-b-p">{order.remoteid}</Z>
    <Z sel=".customer-b-p">{order.custom.customer.full_name}</Z>
    <Z sel=".address-b-p">{order.custom.billing_address}</Z>
    <Z sel=".quantity-b-p">{order.items}</Z>
  </JSXZ>))
 }
})

var Page = createReactClass( {
  render(){
    return <div>
      <JSXZ in="orders" sel=".container">
        <Z sel=".t-body"><Table/></Z>
      </JSXZ>
    </div>
  }
})

ReactDOM.render(
  <Page/>,
  document.getElementById('root')
)
