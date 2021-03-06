"
Test case implements some assert code and setup. 
"
Class {
	#name : #FogTestCase,
	#superclass : #TestCase,
	#instVars : [
		'connection',
		'session'
	],
	#category : 'FogCommunicationTests'
}

{ #category : #running }
FogTestCase >> assert: anObject isKindOf: aClass [
	self assert: (anObject isKindOf: aClass)
]

{ #category : #converting }
FogTestCase >> assertEntityFromMessage: aMessage equalsToJson: aString [
	| entity expected |
	entity := connection transferEntityFromMessage: aMessage.
	entity := self transferEntityFromJsonString: (NeoJSONWriter toString: entity).
	expected := self transferEntityFromJsonString: aString.
	self assert: entity equals: expected
]

{ #category : #running }
FogTestCase >> setUp [
	super setUp.
	connection := FogConnection on: self url.
	session := connection nonCachedSession .
]

{ #category : #running }
FogTestCase >> tearDown [
	super tearDown.
	session finalize
]

{ #category : #'as yet unclassified' }
FogTestCase >> transferEntityFromJsonString: aString [
	| entity message |
	entity := (NeoJSONReader on: aString readStream) next.
	message := FogMessage new
		method: (entity at: #method);
		parameters: (entity at: #params);
		yourself.
	^ FogTransferEntity new
		id: (entity at: #id);
		jsonrpc: (entity at: #jsonrpc);
		message: message;
		yourself
]

{ #category : #running }
FogTestCase >> url [
	^ 'http://localhost:8545'
]
