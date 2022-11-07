Class isi.sqlbuilder.CodeMapping Extends %Persistent [ SqlTableName = CODEMAPPING ]
{

Property Code As %String;

Property Value As %String;

Index PKIDX On Code [ PrimaryKey ];

Query viewMappedObs() As %SQLQuery [ SqlView, SqlViewName = viewMappedObs ]
{
    select obs.Code, obs.Display, map.Value as NewCode  from DEMO.Observation obs left join isi_sqlbuilder.CODEMAPPING map on obs.Code=map.Code
}

Storage Default
{
<Data name="CodeMappingDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Code</Value>
</Value>
<Value name="3">
<Value>Value</Value>
</Value>
</Data>
<DataLocation>^isi.sqlbuilder.CodeMappingD</DataLocation>
<DefaultData>CodeMappingDefaultData</DefaultData>
<IdLocation>^isi.sqlbuilder.CodeMappingD</IdLocation>
<IndexLocation>^isi.sqlbuilder.CodeMappingI</IndexLocation>
<StreamLocation>^isi.sqlbuilder.CodeMappingS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
