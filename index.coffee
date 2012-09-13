Backbone = require 'backbone'
logr = require('node-logr').getLogger("backbone-typed")

exports.TypedModel = class TypedModel extends Backbone.Model

	set : (key, value, options)->

		attrs = attr = val = null

		if key == Object(key) || key == null # Object(obj) - replaced dependecy on underscore call to _.isObject
			attrs = key
			options = value
		else
			attrs = {}
			attrs[key] = value
		
		if this.types && attrs
			keys = Object.keys(attrs)
			for i in keys

				if this.types[i] and attrs[i] != null and	attrs[i] != undefined
					switch this.types[i]
						when 'String' then if attrs[i]? then attrs[i] = String(attrs[i])
						when 'Integer' then if attrs[i]?
							if isNaN(attrs[i]) then ( exports._logDataDrop(i, attrs[i], this.types[i]) ;  attrs[i] = null )
							else attrs[i] = parseInt(attrs[i])
						when 'Float' then if attrs[i]? 
							if isNaN(attrs[i]) then ( exports._logDataDrop(i, attrs[i], this.types[i]) ;  attrs[i] = null )
							else attrs[i] = parseFloat(attrs[i])
						when 'Boolean'
							attrs[i] = switch attrs[i]
								when "true","1" then true
								when "false", "0" then false
								else !!attrs[i]
						else
							if this.types[i].prototype?.__typeName and this.types[i](attrs[i]) then  #do nothing, its all good!
							else
								typedSet = if typeof this.types[i] is "string" then this.types[i] else this.types[i].prototype?.__typeName
								exports._logDataDrop(i, attrs[i], typedSet)
								attrs[i] = null # dont allow value in
		
		super(key, value, options)


exports._logDataDrop = (name, originalVal, typed)->
	logr.error("backbone-typed nulled value of:\"#{name}\" value:\"#{originalVal}\" type:\"#{typed}\"")

exports.Types = {
	"String"
	"Integer"
	"Float"
	"Boolean"
	"Enum" : (obj)->
		_vals = (value for name,value of obj)
		exports._getSignedProtoFunc( "Enum", (lookup)->
			lookup in _vals
		)
}



exports._getSignedProtoFunc = (typeName, callme)->
	inner = ()-> callme.apply(this, arguments)
	inner.prototype.__typeName = typeName
	inner
