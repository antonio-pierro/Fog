Extension { #name : #FogContractInstanceBind }

{ #category : #'*FogBi2' }
FogContractInstanceBind >> gtInspeactorInspector: composite [
	<gtInspectorPresentationOrder: 0>
	FogViewer new
		instance: self;
		gtInspeactorInspectorNavigation: composite;
		yourself
]
