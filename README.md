backbone-typed
==============

Run-time type support for backbone models

Backbone-Typed extends the Backbone model and provides an optional Type system on top of the default models.
The system is provided in run time, and is optimistic, if the value can be converted to the needed type it will, if not, it will be nulled and logged

Examples writtein in Coffee-Script but source is compiled to JS so no need to have CS installed at run time.

## Installation

	npm install backbone-typed

## Usage

	typed = require 'backbone-typed'
	TypedModel = typed.TypedModel
	Types = typed.Types

### Features

```coffeescript

enumLike : {
	"OPTION_1"
	"OPTION_2"
	"OPTION_3"
	"OPTION_4"
}

class MyTypedModel extends TypedModel
	defaults : { param1: null, param2: null, param3: null }
	types : {param1: Types.String, param2: Types.Integer, param3: Types.Enum(enumLike)}


myTypedModel = new MyTypedModel({param1: "im a string", param2: "1337", param3: enumLike.OPTION_1})
console.log myTypedModel.toJSON()
=> { param1: "im a string", param2: 1337, param3: "OPTION_1" }

# now things get interesting...

myTypedModel2 = new MyTypedModel({param1: 100, param2: "bzzzz", param3: "NOT A REAL OPTION"})
console.log myTypedModel2.toJSON()
=> backbone-typed :: 2012-9-13 20:10:3.235 :: ERROR :: backbone-typed nulled value of:"param2" value:"bzzzz" type:"Integer"
=> backbone-typed :: 2012-9-13 20:10:3.235 :: ERROR :: backbone-typed nulled value of:"param3" value:"NOT A REAL OPTION" type:"Enum"
=> { param1: "100", param2: null, param3: null }

```


See more examples in specs.

## Future

Option to create your own typed


## License

MIT