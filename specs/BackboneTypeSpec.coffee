typed = require '../'
TypedModel = typed.TypedModel
Types = typed.Types


describe "Backbone Typed", ->

	it "enforces String",->
		class StringTyped extends TypedModel
			defaults : { checkMe : null }
			types : { checkMe : Types.String }

		st = new StringTyped({checkMe : "this is a string"})
		stBad = new StringTyped({checkMe : 5})

		expect(st.get("checkMe")).toEqual("this is a string")
		expect(stBad.get("checkMe")).toEqual("5")
		expect(stBad.get("checkMe")).not.toEqual(5)

	it "enforces Integer",->
		class IntegerTyped extends TypedModel
			defaults : {checkMe : null}
			types : {checkMe : Types.Integer}

		spyOn(typed, "_logDataDrop")

		it = new IntegerTyped({checkMe : 200})
		it2 = new IntegerTyped({checkMe : 200.20})
		it3 = new IntegerTyped({checkMe : "30"})
		it4 = new IntegerTyped({checkMe : null})
		it5 = new IntegerTyped({checkMe : "badval"})

		expect(typed._logDataDrop).toHaveBeenCalledWith("checkMe", "badval", Types.Integer.toString())

		expect(it.get("checkMe")).toEqual(200)
		expect(it2.get("checkMe")).toEqual(200)
		expect(it3.get("checkMe")).toEqual(30)
		expect(it4.get("checkMe")).toBeNull()
		expect(it5.get("checkMe")).toBeNull()


	it "enforces Float", ->
		class FloatTyped extends TypedModel
			defaults : {checkMe : null}
			types : {checkMe: Types.Float}

		spyOn(typed, "_logDataDrop")

		ft = new FloatTyped({checkMe : 0.0})
		ft2 = new FloatTyped({checkMe : 1.0})
		ft3 = new FloatTyped({checkMe : 100})
		ft4 = new FloatTyped({checkMe : "100.1"})
		ft5 = new FloatTyped({checkMe : 0})
		ft6 = new FloatTyped({checkMe : null})
		ft7 = new FloatTyped({checkMe : "Zz.zZz."})

		expect(typed._logDataDrop).toHaveBeenCalledWith("checkMe", "Zz.zZz.", Types.Float.toString())

		expect(ft.get("checkMe")).toEqual(0)
		expect(ft2.get("checkMe")).toEqual(1)
		expect(ft3.get("checkMe")).toEqual(100)
		expect(ft4.get("checkMe")).toEqual(100.1)
		expect(ft5.get("checkMe")).toEqual(0)
		expect(ft6.get("checkMe")).toEqual(null)
		expect(ft7.get("checkMe")).toEqual(null)


	it "enforces Boolean", ->
		class BolTyped extends TypedModel
			defaults : {checkMe: null}
			types : {checkMe : Types.Boolean}

		bt = new BolTyped({checkMe: true})
		bt2 = new BolTyped({checkMe: false})
		bt3 = new BolTyped({checkMe: null})
		bt4 = new BolTyped({checkMe: 5})
		bt5 = new BolTyped({checkMe: "true"})
		bt6 = new BolTyped({checkMe: "false"})
		bt7 = new BolTyped({checkMe: 0})


		expect(bt.get("checkMe")).toEqual(true)
		expect(bt2.get("checkMe")).toEqual(false)
		expect(bt3.get("checkMe")).toEqual(null)
		expect(bt4.get("checkMe")).toEqual(true)
		expect(bt5.get("checkMe")).toEqual(true)
		expect(bt6.get("checkMe")).toEqual(false)
		expect(bt7.get("checkMe")).toEqual(false)



	it "enforces Enum", ->

		myEnum = {
			"First"
			"Second"
			"Third"
		}
		class EnumTyped extends TypedModel
			defaults : {checkMe : null}
			types : {checkMe : Types.Enum(myEnum)}

		spyOn(typed, "_logDataDrop")

		et = new EnumTyped({checkMe: myEnum.First})
		et2 = new EnumTyped({checkMe: myEnum.Second})
		et3 = new EnumTyped({checkMe: myEnum.Third})
		et4 = new EnumTyped({checkMe: "NOTFROMENUM"})
		expect(typed._logDataDrop).toHaveBeenCalledWith("checkMe", "NOTFROMENUM", Types.Enum().toString())
		et5 = new EnumTyped({checkMe: null})
		et6 = new EnumTyped({checkMe: [myEnum.First]})
		expect(typed._logDataDrop).toHaveBeenCalledWith("checkMe", [myEnum.First], Types.Enum().toString())

		expect(et.get("checkMe")).toEqual(myEnum.First)
		expect(et2.get("checkMe")).toEqual(myEnum.Second)
		expect(et3.get("checkMe")).toEqual(myEnum.Third)
		expect(et4.get("checkMe")).toEqual(null)
		expect(et5.get("checkMe")).toEqual(null)
		expect(et6.get("checkMe")).toEqual(null)
		



	it "supports a complex model",->

		options = {
			"OPTION_1"
			"OPTION_2"
			"OPTION_3"
		}

		class ComplexClass extends TypedModel
			defaults : {first: null, second: null, third: null}
			types : {first: Types.Integer, second: Types.Enum(options)}

		cc = new ComplexClass()
		cc.set({first: "55", second: options.OPTION_1, third: "blahblahblah"})
		expect(cc.get("first")).toEqual(55)
		expect(cc.get("second")).toEqual(options.OPTION_1)
		expect(cc.get("third")).toEqual("blahblahblah")

		cc.set({first:"blahblahblah", second: options.OPTION_3, third: {}})
		expect(cc.get("first")).toEqual(null)
		expect(cc.get("second")).toEqual(options.OPTION_3)
		expect(cc.get("third")).toEqual({})


	it "supports model inheritance", ->

		class GrampsModel extends TypedModel
			defaults : { grampsOne:null, grampsTwo : null }
			types : { grampsOne: Types.Integer , grampsTwo : Types.String }

		class ParentModel extends GrampsModel
			defaults : { parentOne:null, parentTwo : null }
			types : { parentOne: Types.Integer , parentTwo : Types.String }

		class ChildModel extends ParentModel
			defaults : { childOne:null, childTwo : null }
			types : { childtOne: Types.Integer , childTwo : Types.String }

		cm = new ChildModel()
		expect(cm.__typesCache__).toEqual({ grampsOne: Types.Integer , grampsTwo : Types.String
			,parentOne: Types.Integer , parentTwo : Types.String
			,childtOne: Types.Integer , childTwo : Types.String  })

		cm.set({ grampsOne: "5", parentTwo: 22 })
		expect(cm.get("grampsOne")).toEqual(5)
		expect(cm.get("parentTwo")).toEqual("22")


	it "can be extended with custom types",->
		myType = typed.signTypeFunction "Custom",(param)->
			return if param is "its me!" then "yes"  else null


		class CustomTyped extends TypedModel
			defaults : {  testMe : null }
			types : { testMe : myType }

		ct = new CustomTyped({testMe : "its me!"})
		expect(ct.get("testMe")).toEqual("yes")
		ct.set({testMe : "its not me!"})
		expect(ct.get("testMe")).toBeNull()

	it "supports array type", ->

		class ArrModel extends TypedModel
			defaults : { arrMem:null }
			types : { arrMem: Types.Array }

		arrModel = new ArrModel({arrMem: ['one', 'two']})
		expect(arrModel.toJSON()).toEqual({arrMem: ['one', 'two']})

		arrModel.set({arrMem: {notArr : true}})
		expect(arrModel.toJSON()).toEqual({arrMem: null})

		arrModel.set({arrMem: "some str"})
		expect(arrModel.toJSON()).toEqual({arrMem: null})

		arrModel.set({arrMem: []})
		expect(arrModel.toJSON()).toEqual({arrMem: []})


	it "has custom type shorthand",->
		class CModel extends TypedModel
                        defaults : { arrMem:null }
                        types : { blah: Types.Custom("Blah", (val)-> return ( if val is "buzz" then val else null ) ) }


		cModel = new CModel({blah: "buzz"})
		expect(cModel.get("blah")).toEqual("buzz")

		cModel.set({blah : "not buzz"})
		expect(cModel.get("blah")).toBeNull()


