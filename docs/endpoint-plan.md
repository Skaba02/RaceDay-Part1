# RaceDay API Endpoint Plan

This document lists every endpoint the RaceDay API will expose, planned before any application code is written. It follows the two system roles: **Organiser** and **Participant**.

## Authentication

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/auth/register | Creates a new user account and assigns a role. | None (public) | { fullName, email, password, role } | 201 Created - new user id and role<br>400 Bad Request - invalid or missing fields<br>409 Conflict - email already registered |
| POST | /api/auth/login | Validates credentials and returns an access token. | None (public) | { email, password } | 200 OK - JWT token and user details<br>401 Unauthorized - invalid credentials |

## User Profile

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/users/me | Returns the profile of the currently logged-in user. | Any (logged in) | None | 200 OK - user profile<br>401 Unauthorized - no valid token |
| PUT | /api/users/me | Updates the profile of the currently logged-in user. | Any (logged in) | { fullName, email } | 200 OK - updated profile<br>400 Bad Request - invalid fields |

## Events

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/events | Lists all events, with optional filters (date, location). | None (public) | None | 200 OK - list of events |
| GET | /api/events/{id} | Returns full details for one event, including its categories. | None (public) | None | 200 OK - event details<br>404 Not Found - event does not exist |
| POST | /api/events | Creates a new event. | Organiser | { title, description, eventDate, location } | 201 Created - new event id<br>400 Bad Request - invalid fields |
| PUT | /api/events/{id} | Updates an event owned by the logged-in Organiser. | Organiser | { title, description, eventDate, location } | 200 OK - updated event<br>403 Forbidden - not the event owner<br>404 Not Found - event does not exist |
| DELETE | /api/events/{id} | Deletes an event owned by the logged-in Organiser. | Organiser | None | 204 No Content<br>403 Forbidden - not the event owner<br>404 Not Found - event does not exist |

## Categories

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/events/{eventId}/categories | Lists all categories for a specific event. | None (public) | None | 200 OK - list of categories<br>404 Not Found - event does not exist |
| POST | /api/events/{eventId}/categories | Adds a new category to an event. | Organiser | { categoryName, distanceKm, maxParticipants } | 201 Created - new category id<br>404 Not Found - event does not exist |
| PUT | /api/categories/{id} | Updates a category's details. | Organiser | { categoryName, distanceKm, maxParticipants } | 200 OK - updated category<br>404 Not Found - category does not exist |
| DELETE | /api/categories/{id} | Removes a category from an event. | Organiser | None | 204 No Content<br>404 Not Found - category does not exist |

## Event Enrolments

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/categories/{id}/enrol | Enrols the logged-in Participant in a category. | Participant | None | 201 Created - enrolment record<br>404 Not Found - category does not exist<br>409 Conflict - already enrolled or category full |
| GET | /api/users/me/enrolments | Lists all enrolments for the logged-in Participant. | Participant | None | 200 OK - list of enrolments |
| GET | /api/categories/{id}/enrolments | Lists all participants enrolled in a category. | Organiser | None | 200 OK - list of enrolments<br>404 Not Found - category does not exist |
| DELETE | /api/enrolments/{id} | Cancels an enrolment belonging to the logged-in Participant. | Participant | None | 204 No Content<br>403 Forbidden - not the enrolment owner<br>404 Not Found - enrolment does not exist |

## Results

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/enrolments/{id}/result | Records a finish time and position for an enrolment. | Organiser | { finishTime, position } | 201 Created - result record<br>404 Not Found - enrolment does not exist<br>409 Conflict - result already recorded |
| GET | /api/categories/{id}/results | Lists all results for a category, ordered by position. | None (public) | None | 200 OK - list of results<br>404 Not Found - category does not exist |
| GET | /api/users/me/results | Lists all results for the logged-in Participant. | Participant | None | 200 OK - list of results |
