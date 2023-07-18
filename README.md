# Salesforce Order Products LWC + Apex

A couple of Lightning Web Components to Handle Products and Orders

## Instructions for setup:

- Create Scratch Org
  - `sfdx force:org:create -f config/project-scratch-def.json -a neworg -d 10 -s`
- Push code to Scratch Org
  - `sfdx force:source:push -u neworg`
- Open your scratch org and start navigating, new LWC should be available in the Order page or ready to be used in the Order page using the Page Builder

## Why Services?
I think that it is cleaner this way, controllers should not have that much logic(that includes SOQL and DMLs),
so a Service/Handler per object works better

## TODO:
- Validations before DMLs and SOQL queries