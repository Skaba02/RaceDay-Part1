# RaceDay - Part 1: System Planning and Database

## Description

RaceDay lets people organise and take part in running events. Someone with the Organiser role sets up an event and adds one or more categories to it, such as a 5km and a 10km option under the same event. Someone with the Participant role can look through the available events, sign up for a category, and check their results after the Organiser has entered them.

This part of the project covers the planning stage only. No application code is written here. The repository contains the Entity Relationship Diagram, the API endpoint plan, and the SQL script used to build the database in SQL Server Management Studio (SSMS).

## Roles

- **Organiser** - the person running the event. Sets up events and their categories, keeps track of who has signed up, and enters each participant's result once the race is finished.
- **Participant** - the person taking part. Looks through upcoming events, joins a category, and checks back later to see their own results.

## Repository Structure

```
/docs
  ERD.png                - Entity Relationship Diagram
  endpoint-plan.md        - Full API endpoint plan
  database.sql            - SQL script to create and seed the database
.github/workflows
  validate-repo.yml       - GitHub Actions workflow checking the /docs folder
README.md
```

## CI/CD

A GitHub Actions workflow (`.github/workflows/validate-repo.yml`) runs on every push and checks that the `/docs` folder exists and contains the ERD, endpoint plan, and SQL script.

**CI/CD screenshot:**

'![CI passing](ci-success.png)'
## Video Walkthrough

`[Insert your unlisted YouTube link here]`

The video covers:
- A walkthrough of the ERD and the reasoning behind the entities and relationships.
- The endpoint plan and why each endpoint was included.
- Running the SQL script live in SSMS.

## Notes

The SQL script in `/docs/database.sql` matches the ERD exactly - six entities, with primary keys, foreign keys, and cardinalities as shown in the diagram.

## Assumptions

- A user can only hold one role at a time - either Organiser or Participant.
- A Participant can enrol in more than one category, but only once per category (enforced by a unique constraint).
- Results are entered by the Organiser after the event has taken place; there is no self-reported result option.
