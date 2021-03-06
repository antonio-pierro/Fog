"
Full contract ob ject. ABI + Binary + Runtime . Normally pointing a block chain deployed contract 
"
Class {
	#name : #FogContractDescription,
	#superclass : #Object,
	#instVars : [
		'binary',
		'runtime',
		'abi',
		'ast',
		'name',
		'mirror',
		'methods',
		'aTypeSet',
		'contract'
	],
	#category : 'FogDB-Meta-Description'
}

{ #category : #accessing }
FogContractDescription >> abi [
	^ abi
]

{ #category : #accessing }
FogContractDescription >> abi: aString [
	abi := aString
]

{ #category : #accessing }
FogContractDescription >> ast [
	^ ast
]

{ #category : #accessing }
FogContractDescription >> ast: anAST [
	ast := anAST
]

{ #category : #'instance creation' }
FogContractDescription >> at: anAddress [
	self error: 'shouldnt call this'.
	^ FogContractInstance new
		address: anAddress;
		contract: self;
		yourself
]

{ #category : #accessing }
FogContractDescription >> binary [
	^ binary
]

{ #category : #accessing }
FogContractDescription >> binary: aString [
	binary := aString asAddress
]

{ #category : #testing }
FogContractDescription >> codeMatchesWith: aCode [
	| addCode |
	addCode := aCode asAddress.
	^ binary = addCode or: [ runtime = addCode or: [ ( addCode size/(addCode minus: runtime) size ) asFloat < self similarityThreshold. ] ]
]

{ #category : #accessing }
FogContractDescription >> contract [
	^ self createContract 
]

{ #category : #'contract generation' }
FogContractDescription >> createContract [
	^ FogContractProxyBuilder new description: self; createContractProxy 
]

{ #category : #accessing }
FogContractDescription >> fromFile [
	^ ' no-file '.
]

{ #category : #testing }
FogContractDescription >> hasAbi [
	^ abi isNotNil
]

{ #category : #testing }
FogContractDescription >> hasAst [
	^ ast isNotNil
]

{ #category : #testing }
FogContractDescription >> hasBinary [
	^ binary isNotNil
]

{ #category : #testing }
FogContractDescription >> hasRuntime [
	^ runtime isNotNil
]

{ #category : #gttools }
FogContractDescription >> inspect: bytecode on: composite title: title [
	^ composite table
		title: title;
		display: [ bytecode ];
		column: 'Address' evaluated: [ :e | e byteNumber asBKHexa: 5 ];
		column: 'Instruction' evaluated: #instruction;
		send: #value
]

{ #category : #gttools }
FogContractDescription >> inspectAbi: composite [
	<gtInspectorPresentationOrder: 5>
	composite text
		title: 'ABI ';
		display: [ self abi ]
]

{ #category : #gttools }
FogContractDescription >> inspectBinary: composite [
	<gtInspectorPresentationOrder: 6>
	(self respondsTo: #mnemonicBinary)
		ifTrue: [ self inspect: self mnemonicBinary content on: composite title: 'Binary Mnemonic' ]
		ifFalse: [ composite text
				title: 'Binary bytecode';
				display: [ self binary ] ]
]

{ #category : #gttools }
FogContractDescription >> inspectConstructor: composite [
	<gtInspectorPresentationOrder: 4>
	composite table
		title: 'Constructor';
		display: [ {self mirror constructor} ];
		column: 'Name' evaluated: #name;
		column: 'Selector' evaluated: #selector;
		column: 'Definition' evaluated: #value;
		send: #value
]

{ #category : #gttools }
FogContractDescription >> inspectDecompilation: composite [
	<gtInspectorPresentationOrder: 8>
	composite text
		title: 'Runtime Decompilation';
		display: [ | decompiler stream |
			decompiler := FogEVMDecompiler new.
			FogEVMAstVariable initialize.
			decompiler decompile: self mnemonicRuntime.
			stream := '' writeStream.
			decompiler extractedMethods do: [ :m | m printOn: stream ].
			stream contents ]
]

{ #category : #gttools }
FogContractDescription >> inspectMethods: composite [
	<gtInspectorPresentationOrder: 2>
	composite table
		title: 'Methods';
		display: [ self mirror instanceMirror methods ];
		column: 'Name' evaluated: #name;
		column: 'Selector' evaluated: #selector;
		column: 'Signature' evaluated: #signature;
		column: 'Definition' evaluated: #value;
		send: #value
]

{ #category : #gttools }
FogContractDescription >> inspectProperties: composite [
	<gtInspectorPresentationOrder: 3>
	composite table
		title: 'Properties';
		display: [ self mirror instanceMirror properties ];
		column: 'Name' evaluated: #name;
		column: 'Definition' evaluated: #value;
		send: #value
]

{ #category : #gttools }
FogContractDescription >> inspectRuntime: composite [
	<gtInspectorPresentationOrder: 7>
	(self respondsTo: #mnemonicRuntime)
		ifTrue: [ self mnemonicRuntime
				ifNotNil: [ :mnem | self inspect: mnem content on: composite title: 'Runtime Mnemonic' ] ]
		ifFalse: [ composite text
				title: 'Runtime bytecode';
				display: [ self runtime ] ]
]

{ #category : #gttools }
FogContractDescription >> inspectSource: composite [
	<gtInspectorPresentationOrder: 0>
	composite text
		title: 'Source';
		display: [ self source ]
]

{ #category : #gttools }
FogContractDescription >> inspectTypes: composite [
	<gtInspectorPresentationOrder: 1>
	composite table
		title: 'Types';
		display: [ self mirror types ];
		column: 'Name' evaluated: #name;
		column: 'Definition' evaluated: #value;
		send: #value
]

{ #category : #accessing }
FogContractDescription >> isFileBased [
	^ false
]

{ #category : #accessing }
FogContractDescription >> mirror [
	mirror := FogMirrorBuilder new
		ast: ast;
		abi: abi;
		mirror.
	^ mirror
]

{ #category : #accessing }
FogContractDescription >> name: aString [ 
	name := aString
]

{ #category : #printing }
FogContractDescription >> printOn: aStream [
	^ aStream
		nextPutAll: 'Contract ';
		nextPutAll: (name ifNil: [ 'Unknown' ])
]

{ #category : #accessing }
FogContractDescription >> runtime [
	^ runtime
]

{ #category : #accessing }
FogContractDescription >> runtime: aString [
	runtime := aString asAddress
]

{ #category : #'as yet unclassified' }
FogContractDescription >> similarityThreshold [
	^ 0
]

{ #category : #accessing }
FogContractDescription >> source [
	^ 'not-source'
]

{ #category : #accessing }
FogContractDescription >> types [
	^ ast types
]

{ #category : #accessing }
FogContractDescription >> versionHash [
	^ binary hash asString
]
