<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_scope_asset_key</fullName>
        <field>Scope_Asset_Key__c</field>
        <formula>Scope__r.Id + &apos;-&apos; +  Asset__r.Id</formula>
        <name>Update scope asset key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update UID for Recommended Assets</fullName>
        <actions>
            <name>Update_scope_asset_key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
