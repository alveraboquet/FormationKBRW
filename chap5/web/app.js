require('!!file-loader?name=[name].[ext]!./index.html')
var ReactDOM = require('react-dom')
var React = require("react")
var createReactClass = require('create-react-class')
var Qs = require('qs')
var Cookie = require('cookie')
require('./webflow/css/tuto.webflow.css');
require('./webflow/css/modal.css');

var XMLHttpRequest = require("xhr2")
var HTTP = new (function(){
  this.get = (url)=>this.req('GET',url)
  this.delete = (url)=>this.req('DELETE',url)
  this.post = (url,data)=>this.req('POST',url,data)
  this.put = (url,data)=>this.req('PUT',url,data)

  this.req = (method,url,data)=> new Promise((resolve, reject) => {
    var req = new XMLHttpRequest()
    req.open(method, url)
    req.responseType = "text"
    req.setRequestHeader("accept","application/json,*/*;0.8")
    req.setRequestHeader("content-type","application/json")
    req.onload = ()=>{
      if(req.status >= 200 && req.status < 300){
      resolve(req.responseText && JSON.parse(req.responseText))
      }else{
      reject({http_code: req.status})
      }
    }
    req.onerror = (err)=>{
      reject({http_code: req.status})
    }
    req.send(data && JSON.stringify(data))
  })
})()

var remoteProps = {
/*  user: (props)=>{
    return {
      url: "/api/me",
      prop: "user"
    }
  },*/
  orders: (props)=>{
/*    if(!props.user)
      return*/
    var qs = {...props.qs}//, user_id: props.user.value.id}
    var query = Qs.stringify(qs)
    return {
      url: "/api/orders" + (query == '' ? '' : '?' + query),
      prop: "orders"
    }
  },
  order: (props)=>{
    return {
      url: "/api/order/" + props.order_id,
      prop: "order"
    }
  }
}

var Child = createReactClass({
  render(){
    var [ChildHandler, ...rest] = this.props.handlerPath
    return <ChildHandler {...this.props} handlerPath={rest} />
  }
})

var DeleteModal = createReactClass({
  render(){
    return <JSXZ in="modal" sel=".modal-wrapper">
      <Z sel=".modal-title">{this.props.title}</Z>
      <Z sel=".modal-message">{this.props.message}</Z>
      <Z sel=".modal-validation" onClick={() => this.props.callback(true)}>Yes</Z>
      <Z sel=".modal-cancel" onClick={() => this.props.callback(false)}>No</Z>
    </JSXZ>
  }
})

var Loader = createReactClass({
  render(){
    return <JSXZ in="loader" sel=".layout"></JSXZ>
  }
})

var Layout = createReactClass({
  getInitialState: function() {
    return {modal: null, loader: {state: false}};
  },
  modal(spec) {
    this.setState({modal: {
      ...spec, callback: (res)=>{
        this.setState({modal: null},()=>{
          if(spec.callback) spec.callback(res)
        })
      }
    }})
  },
  loader(promise) {
    return new Promise(resolve => {
      this.setState({
        ...this.state,
        loader: {state: true, callback: promise.then(() => {
          resolve(this.setState({
            ...this.state,
            loader: {state: false}
          }))
        })}
      })
    })
  },
  render(){
    var props = {
      ...this.props, modal: this.modal, loader: this.loader
    }
    var modal_component = {
      'delete': (props) => <DeleteModal {...props}/>
    } [this.state.modal && this.state.modal.type];
    modal_component = modal_component && modal_component(this.state.modal)

    var loader_component = {
      true: <Loader />
    } [this.state.loader.state];

    return <JSXZ in="orders" sel=".layout">
        <Z sel=".loader-wrapper" className={cn(classNameZ, {'hidden': !loader_component})}>
          {loader_component}
       </Z>
        <Z sel=".modal-wrapper" className={cn(classNameZ, {'hidden': !modal_component})}>
          {modal_component}
        </Z>
        <Z sel=".layout-container">
          <this.props.Child {...props}/>
        </Z>
      </JSXZ>
  }
})

var Header = createReactClass({
  render(){
    return <JSXZ in="orders" sel=".header">
        <Z sel=".header-container">
          <this.props.Child {...this.props}/>
        </Z>
      </JSXZ>
  }
})

var Orders = createReactClass({
  statics: {
    remoteProps: [remoteProps.orders]
  },
  deleteLine(key) {
    this.props.modal({
      type: 'delete',
      title: 'Order deletion',
      message: `Are you sure you want to delete this ?`,
      callback: (value)=>{
        if (value) {
          req = HTTP.req('GET', '/delete/?key=' + key)
          this.props.loader(req).then(
            () => {
              var newProps = {...this.props}
              delete newProps.orders
              browserState = newProps
              GoTo('orders', '', '')
            }
          )
        }
      }
    })
  },
  render(){
    var props = {...this.props, callback: this.deleteLine}
    return <JSXZ in="orders" sel=".orders">
        <Z sel=".t-body">
          <TableOrders {...props}/>
        </Z>
      </JSXZ>
  }
})

var Order = createReactClass({
  statics: {
    remoteProps: [remoteProps.order]
  },
  render(){
    var value = this.props.order.value
    return <JSXZ in="order" sel=".order">
      <Z sel=".client-p-data">{value.custom.customer.prefix} {value.custom.customer.full_name}</Z>
      <Z sel=".address-p-data">
        {value.custom.billing_address.street} {value.custom.billing_address.postcode} {value.custom.billing_address.city}
      </Z>
      <Z sel=".number-p-data">{value.remoteid}</Z>
      <Z sel=".t-body">
        <TableOrder {...this.props.order}/>
      </Z>
    </JSXZ>
  }
})

var TableOrder = createReactClass( {
  render(){
    return this.props.value.custom.items.map((item, idx) => (<JSXZ in="order" sel=".t-row" key={idx}>
        <Z sel=".name-p">{item.product_title}</Z>
        <Z sel=".quantity-p">{item.quantity_to_fetch}</Z>
        <Z sel=".price-p">{item.price}</Z>
        <Z sel=".total-p">{item.price * item.quantity_to_fetch}</Z>
      </JSXZ>
    ))}
})

var TableOrders = createReactClass( {
  render(){
    return this.props.orders.value.map(order => {
      var key = Object.keys(order)[0]
      var data = order[key]
      return (<JSXZ in="orders" sel=".t-row" key={key}>
        <Z sel=".number-b-p">{data.remoteid}</Z>
        <Z sel=".customer-b-p">{data.custom.customer.full_name}</Z>
        <Z sel=".address-b-p">{data.custom.billing_address.street}</Z>
        <Z sel=".quantity-b-p">{data.custom.items.length}</Z>
        <Z sel=".pay-status-p">{data.status.state}</Z>
        <Z sel=".details-b-p" onClick={() => GoTo('order', key, '')}></Z>
        <Z sel=".delete-p" onClick={() => this.props.callback(key)}></Z>
      </JSXZ>)
    })
  }
})

var ErrorPage = createReactClass({
  render(){
    return <div>
      <p> {this.props.code} {this.props.message} </p>
    </div>
  }
})

var browserState = {Child: Child}

var routes = {
  "orders": {
    path: (params) => {
      return "/";
    },
    match: (path, qs) => {
      return (path == "/") && {handlerPath: [Layout, Header, Orders]} // Note that we use the "&&" expression to simulate a IF statement
    }
  }, 
  "order": {
    path: (params) => {
      return "/order/" + params;
    },
    match: (path, qs) => {
      var r = new RegExp("/order/([^/]*)$").exec(path)
      return r && {handlerPath: [Layout, Header, Order],  order_id: r[1]} // Note that we use the "&&" expression to simulate a IF statement
    }
  }
}

var cn = function(){
  var args = arguments, classes = {}
  for (var i in args) {
    var arg = args[i]
    if(!arg) continue
    if ('string' === typeof arg || 'number' === typeof arg) {
      arg.split(" ").filter((c)=> c!="").map((c)=>{
        classes[c] = true
      })
    } else if ('object' === typeof arg) {
      for (var key in arg) classes[key] = arg[key]
    }
  }
  return Object.keys(classes).map((k)=> classes[k] && k || '').join(' ')
}

var GoTo = (route, params, query) => {
  var qs = Qs.stringify(query)
  var url = routes[route].path(params) + ((qs=='') ? '' : ('?'+qs))
  history.pushState({}, "", url)
  onPathChange()
}

function addRemoteProps(props){
  return new Promise((resolve, reject)=>{
    var remoteProps = Array.prototype.concat.apply([],
      props.handlerPath
        .map((c)=> c.remoteProps) // -> [[remoteProps.orders], null]
        .filter((p)=> p) // -> [[remoteProps.orders]]
    )
    remoteProps = remoteProps
      .map((spec_fun)=> spec_fun(props) ) // [{url: '/api/orders', prop: 'orders'}]
      .filter((specs)=> specs) // get rid of undefined from remoteProps that don't match their dependencies
      .filter((specs)=> !props[specs.prop] ||  props[specs.prop].url != specs.url) // get rid of remoteProps already resolved with the url
    if(remoteProps.length == 0)
      return resolve(props)
          // All remoteProps can be queried in parallel. This is just the function definition, see its use below.
    const promise_mapper = (spec) => {
      // we want to keep the url in the value resolved by the promise here : spec = {url: '/api/orders', value: ORDERS, prop: 'orders'}
      return HTTP.get(spec.url).then((res) => { spec.value = res; return spec })
    }

    const reducer = (acc, spec) => {
      // spec = url: '/api/orders', value: ORDERS, prop: 'user'}
      acc[spec.prop] = {url: spec.url, value: spec.value}
      return acc
    }

    const promise_array = remoteProps.map(promise_mapper)
    return Promise.all(promise_array)
      .then(xs => xs.reduce(reducer, props), reject)
      .then((p) => {
      // recursively call remote props, because props computed from
      // previous queries can give the missing data/props necessary
      // to define another query
        return addRemoteProps(p).then(resolve, reject)
      }, reject)
  })
}

function onPathChange() {
  var path = location.pathname
  var qs = Qs.parse(location.search.slice(1))
  var cookies = Cookie.parse(document.cookie)

  browserState = {
    ...browserState, 
    path: path, 
    qs: qs, 
    cookie: cookies
  }
  var route
  
  // We try to match the requested path to one our our routes
  for (var key in routes) {
    routeProps = routes[key].match(path, qs)
    if (routeProps){
        route = key
          break;
    }
  }

  // We add the route name and the route Props to the global browserState
  browserState = {
    ...browserState,
    ...routeProps,
    route: route
  }

  // If the path in the URL doesn't match with any of our routes, we render an Error component (we will have to create it later)
  if(!route)
    return ReactDOM.render(<ErrorPage message={"Not Found"} code={404}/>, document.getElementById('root'))
  addRemoteProps(browserState).then(
    (props) => {
      browserState = props
      // Log our new browserState
      console.log(browserState)
      // Render our components using our remote data
      ReactDOM.render(<Child {...browserState}/>, document.getElementById('root'))
    }, (res) => {
      ReactDOM.render(<ErrorPage message={"Shit happened"} code={res.http_code}/>, document.getElementById('root'))
    })
}

window.addEventListener("popstate", ()=>{ onPathChange() })
onPathChange()
