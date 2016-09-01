<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>E2_Populate_LOE_on_Complexity</fullName>
        <description>Populate LOE on complexity</description>
        <field>LOE_Hrs__c</field>
        <formula>IF(
 OR(ISPICKVAL(Complexity__c, &apos;&apos;), ISPICKVAL(Complexity__c, &apos;Medium&apos;)), 
 Direct_Medium_Hrs__c,
IF(
 ISPICKVAL(Complexity__c, &apos;High&apos;),
 Direct_High_Hrs__c,
IF(
 ISPICKVAL(Complexity__c, &apos;Low&apos;),
Direct_Low_Hrs__c, 0)))</formula>
        <name>E2 Populate LOE on Complexity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>E2 Populate LOE Depending Complexity</fullName>
        <actions>
            <name>E2_Populate_LOE_on_Complexity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>E2_Scope__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This rule will populate the LOE Hrs field on the scope record based on the complexity selected.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
