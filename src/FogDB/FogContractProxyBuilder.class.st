"
Contract proxy builder,  generates a proxy class for a given contract description 
"
Class {
	#name : #FogContractProxyBuilder,
	#superclass : #Object,
	#instVars : [
		'description',
		'name'
	],
	#category : 'FogDB-Domain-Contracts'
}

{ #category : #'building names' }
FogContractProxyBuilder >> buildCategoryName [
	^ 'Fog-Generated-' , self generationName
]

{ #category : #'build - private' }
FogContractProxyBuilder >> buildClassComment [
	^ '
	Class generated by {1} on {2}
	Based on file: {3}.
	Readonly slots. 
	Trait based behaviour. 
	Source code: 
	====================================================
	{4}
	====================================================
'
		format:
			{self class name.
			DateAndTime now asString.
			description fromFile asString.
			description source}
]

{ #category : #'building names' }
FogContractProxyBuilder >> buildClassName [
	^ ('Contract' , self generationName) asSymbol
]

{ #category : #'building slots - variables' }
FogContractProxyBuilder >> buildClassVariables [
	^ ''
]

{ #category : #'building slots - variables' }
FogContractProxyBuilder >> buildInstanceSlots [
	^ description mirror instanceMirror properties
		collect: [ :p | p name asSymbol => FogContractPropertySlot ]
]

{ #category : #'build - private' }
FogContractProxyBuilder >> buildTraitComment [
	^ '
	Contract behaviour Trait generated by {1} on {2}
	Based on file: {3}.
	Intended to be applyied on a {4} subclass . 
	ABI  
	====================================================
	{5}
	====================================================
'
		format:
			{self class name.
			DateAndTime now asString.
			description fromFile asString.
			FogContractProxy name.
			description abi asString}
]

{ #category : #'building names' }
FogContractProxyBuilder >> buildTraitName [
	^ ('TContract' , self generationName) asSymbol
]

{ #category : #'building methods' }
FogContractProxyBuilder >> compilableClassMethod: aFogMethodMirror [
	| variables |
	variables := '{' , (' . ' join: aFogMethodMirror parameters variables) , '}'.
	^ '{1}
	| instance |
	instance := (self mirror method: #{2}) using: self session 
				applyOn: self contractDescription 
				valueWithArguments: {3} 
				from: self session sessionAccount.
	^ self forInstance: (instance waitIsReady; yourself) at: #latest.
'
		format:
			{aFogMethodMirror selectorWithNames.
			aFogMethodMirror selector.
			variables}
]

{ #category : #'building methods' }
FogContractProxyBuilder >> compilableClassMethodAmount: aFogMethodMirror [
	| variables space |
		space := aFogMethodMirror hasParameters
		ifTrue: [ ' ' ]
		ifFalse: [ '' ].
	variables := '{' , (' . ' join: aFogMethodMirror parameters variables) , '}'.
	^ '{1}{4}amount: anAmountOfWeiToTransmitToTheContractOnDeploy
	| instance |
	instance := (self mirror method: #{2}) 
		using: self session 
		applyOn: self contractDescription 
		valueWithArguments: {3} 
		from: self session sessionAccount 
		amount: anAmountOfWeiToTransmitToTheContractOnDeploy.
	^ self forInstance: (instance waitIsReady; yourself) at: #latest.
'
		format:
			{aFogMethodMirror selectorWithNames.
			aFogMethodMirror selector.
			variables.
			space}
]

{ #category : #'building methods' }
FogContractProxyBuilder >> compilableClassMethods [
	^ {(self compilableClassMethod: description mirror constructor).
	(self compilableClassMethodAmount: description mirror constructor).
	self compilableVersionMethod.
	self compilableDescriptionNameAccessor}
]

{ #category : #'building methods' }
FogContractProxyBuilder >> compilableDescriptionNameAccessor [
	^ 'contractDescriptionName
	^ ''{1}''' format: {description name}
]

{ #category : #'building methods' }
FogContractProxyBuilder >> compilableInstanceMethods [
	^ description mirror instanceMirror methods collect: [ :m | self compilableMethod: m ]
]

{ #category : #'building methods' }
FogContractProxyBuilder >> compilableInstanceMethodsWithAmounts [
	^ description mirror instanceMirror methods collect: [ :m | self compilableMethodAmount: m ]
]

{ #category : #'building methods' }
FogContractProxyBuilder >> compilableMethod: aFogMethodMirror [
	| variables |
	variables := '{' , (' . ' join: aFogMethodMirror parameters variables) , '}'.
	^ '{1}
	| method |
	method := (self mirror method: #{2}).
	(method isStateModifier and: [ self blockReference ~= #latest ]) ifTrue: [ 
		^ self error:''the current proxy is pointing to an existing block. Only non-transactional methods can be executed''. 
	].

	^ method using: self session applyOn: self instance at: self blockReference valueWithArguments: {3} from: self session sessionAccount.
'
		format:
			{aFogMethodMirror selectorWithNames.
			aFogMethodMirror selector.
			variables}
]

{ #category : #'building methods' }
FogContractProxyBuilder >> compilableMethodAmount: aFogMethodMirror [
	| variables space |
	space := aFogMethodMirror hasParameters
		ifTrue: [ ' ' ]
		ifFalse: [ '' ].
	variables := '{' , (' . ' join: aFogMethodMirror parameters variables) , '}'.
	^ '{1}{4}amount: anAmountInWeiForTransmitingWithTheApplication
	| method |
	method := (self mirror method: #{2}).
	(method isStateModifier and: [ self blockReference ~= #latest ]) ifTrue: [ 
		^ self error:''the current proxy is pointing to an existing block. Only non-transactional methods can be executed''. 
	].

	^ method using: self session 
				applyOn: self instance 
				at: self blockReference 
				valueWithArguments: {3} 
				from: self session sessionAddress 
				amount: anAmountInWeiForTransmitingWithTheApplication.
'
		format:
			{aFogMethodMirror selectorWithNames.
			aFogMethodMirror selector.
			variables.
			space}
]

{ #category : #'building methods' }
FogContractProxyBuilder >> compilableVersionMethod [
	^ 'versionHash
	^ ''{1}''' format: {description versionHash}
]

{ #category : #'build - private' }
FogContractProxyBuilder >> createClassUsing: aFogContractTrait [
	| class |
	class := FogContractProxy
		subclass: self buildClassName asSymbol
		uses: aFogContractTrait
		slots: self buildInstanceSlots
		classVariables: self buildClassVariables
		category: self buildCategoryName.
	class comment: self buildClassComment.
	^ class
]

{ #category : #build }
FogContractProxyBuilder >> createContractProxy [
	^ Smalltalk
		at: self buildClassName asSymbol
		ifAbsent: [ self createClassUsing: self createTrait ]
]

{ #category : #'build - private' }
FogContractProxyBuilder >> createTrait [
	| trait |
	trait := Trait named: self buildTraitName uses: {} category: self buildCategoryName.
	self compilableInstanceMethods do: [ :c | trait compile: c classified: 'generated-mirror-based' ].
		self compilableInstanceMethodsWithAmounts do: [ :c | trait compile: c classified: 'generated-payable-mirror-based' ].
	self compilableClassMethods do: [ :c | trait classTrait compile: c classified: 'generated-mirror-based' ].
	trait comment: self buildTraitComment.
	^ trait
]

{ #category : #accessing }
FogContractProxyBuilder >> description: aDescription [
	description := aDescription
]

{ #category : #'building names' }
FogContractProxyBuilder >> generationName [
	^ name
		ifNil: [ name := '' join: (('_' split: description name) collect: [ :d | d capitalized ]).
			name := name copyReplaceAll: '-' with: '' ]
]