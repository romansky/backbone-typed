Backbone = require 'backbone'
logr = require('node-logr').getLogger("backbone-typed")

exports.TypedModel = class TypedModel extends Backbone.Model

	__typesCache__ : false

	set : (key, value, options)->

		attrs = attr = val = null

		if key == Object(key) || key == null # Object(obj) - replaced dependecy on underscore call to _.isObject
			attrs = key
			options = value
		else
			attrs = {}
			attrs[key] = value


		if @__typesCache__ is false
			parentTypes = []
			aModel = this
			while (aModel)
				if aModel.types then parentTypes.push( aModel.types )
				aModel = aModel.constructor.__super__
			if parentTypes.length > 0
				@__typesCache__ = {}
				for parentType in parentTypes
					for _prop, _val of parentType
						@__typesCache__[_prop] = _val
			else
				@__typesCache__ = null


		if @__typesCache__ && attrs
			keys = Object.keys(attrs)
			for memberName in keys
				if this.__typesCache__[memberName] and attrs[memberName] != null and	attrs[memberName] != undefined
					typedSet = if typeof this.__typesCache__[memberName] is "string" then this.__typesCache__[memberName] else this.__typesCache__[memberName].prototype?.__typeName
					if this.__typesCache__[memberName].prototype?.__typeName
						origVal = attrs[memberName]
						attrs[memberName] = this.__typesCache__[memberName](attrs[memberName])
						if origVal and attrs[memberName] is null then exports._logDataDrop(memberName, origVal, typedSet)
					else
						exports._logDataDrop(memberName, attrs[memberName], typedSet)
						attrs[memberName] = null # dont allow value in

		super(key, value, options)


exports._logDataDrop = (name, originalVal, typed)->
	logr.error("backbone-typed nulled value of:\"#{name}\" value:\"#{originalVal}\" type:\"#{typed}\"")



exports.signTypeFunction = (typeName, callme)->
	inner = ()-> callme.apply(this, arguments)
	inner.prototype.__typeName = typeName
	inner.toString = ()-> inner.prototype.__typeName
	inner

exports.Types = {
	String : exports.signTypeFunction "String", (param)->
		if param then String(param) else null
	Integer: exports.signTypeFunction "Integer", (param)->
		return ( if not isNaN(param) then parseInt(param) else null )
	Float : exports.signTypeFunction "Float", (param)->
		return ( if not isNaN(param) then parseFloat(param) else null )
	Boolean : exports.signTypeFunction "Boolean", (param)->
		return switch param
			when "true","1" then true
			when "false", "0" then false
			else !!param
	Enum : (obj)->
		_vals = (value for name,value of obj)
		exports.signTypeFunction( "Enum", (lookup)->
			_vals.filter((v)-> v==lookup)[0] || null
		)

	Array : exports.signTypeFunction "Array", (param)->
		return ( if not Array.isArray(param) then null else param )
}



