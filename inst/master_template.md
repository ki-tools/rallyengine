# Master Rally Template

Version 0.3.2

*This template is to be filled out for each rally. It is meant to be worked on collaboratively by all rally participants throughout the course of the rally.*

*All rally outputs (such as the rally overview, rally dashboard, and initial drafts of report-out presentations / documents) will be automatically generated from this content, so please take care in filling the entries out clearly.*

*Each template entry provides you with a description of what type of content should be provided, as well as an assignee and a due date. In most cases, sample text already exists for you to edit.*

*To include figures, use the following, filling in the {} as necessary:*

```r
Figure:
- {OSF link to hi-res png image (e.g. https://osf.io/xxxxx/)}
- {Informative title}
- {Explanation of why figure is important / takehome message about the figure}
```

*To include tables, use the following:*

```r
Table:
- {OSF link to hi-res png image of the table (e.g. https://osf.io/xxxxx/)}
- {Informative title}
- {Explanation of why table is important / takehome message about the table}
```

*For more information about using the master template, read [here](https://osf.io/s7p4z/wiki/home/).*

## Rally Number

`[id: number]`
`[description: The rally number (e.g. 1A, 1B, 2A, etc.)]`
`[content_type: single line]`
`[required: true]`
`[assignee: rally master]`
`[due: rally kickoff]`

10Z

## Rally Title

`[id: title]`
`[description: The title of the rally - be descriptive.]`
`[content_type: single line]`
`[required: true]`
`[assignee: rally master]`
`[due: rally kickoff]`

Rally title text here...

## Rally OSF ID

`[id: osf_id]`
`[description: The OSF ID of the rally (this is the 5 characters in the rally component address https://osf.io/xxxxx).]`
`[content_type: OSF ID]`
`[required: true]`
`[assignee: rally master]`
`[due: rally kickoff]`

xxxxx

## Previous Rally OSF ID

`[id: previous]`
`[description: If this is a continuation of a previous rally, provide the OSF ID (the 'xxxxx' in the previous rally component address https://osf.io/xxxxx/), otherwise leave blank.]`
`[content_type: OSF ID]`
`[required: false]`
`[assignee: rally master]`
`[due: rally kickoff]`

## Tags

`[id: tags]`
`[description: A comma-separated list of terms that describe the rally.]`
`[content_type: comma separated]`
`[required: true]`
`[assignee: rally master]`
`[due: rally kickoff]`

tag1, tag2, tag3

## Timeline

`[id: timeline]`
`[description: Rally start and end dates. Fill in {} below.]`
`[content_type: start and end dates]`
`[required: true]`
`[assignee: rally master]`
`[due: rally kickoff]`

Start: {mm/dd/yy}
End: {mm/dd/yy}

## Participants

`[id: participants]`
`[description: List of rally participants and affiliations / roles. Fill in {} below and repeat the line for each participant.]`
`[content_type: participant list]`
`[required: true]`
`[assignee: rally master]`
`[due: rally kickoff]`

- {name}, {organization}, {email}, {role - usually one of "data scientist", "domain expert", "rally master"}
- {name}, {organization}, {email}, {role - usually one of "data scientist", "domain expert", "rally master"}
- {name}, {organization}, {email}, {role - usually one of "data scientist", "domain expert", "rally master"}

## Problem Statement

`[id: problem]`
`[description: Fill in the {} below appropriately.]`
`[content_type: single line]`
`[required: true]`
`[assignee: rally master]`
`[due: rally kickoff]`

This rally will {primary objective} for {target audience} so that {end user} can {primary use case} thereby {Foundation / PST objective}.

## Rally Focus

`[id: focus]`
`[description: What is the focus for this rally?]`
`[content_type: single paragraph]`
`[required: true]`
`[assignee: rally master]`
`[due: rally kickoff]`

Provide rally focus text here...

## Rally Question

`[id: question]`
`[description: Has to be refined by rally team so that it represents the problem that you are working on.]`
`[content_type: single paragraph]`
`[required: true]`
`[assignee: rally master]`
`[due: rally kickoff]`

Rally question text here...

## HBGD Prioritized Question

`[id: hbgd_question_id]`
`[description: From http://bit.ly/hbgd-rallyquestions, find the ID of the question that this rally is answering.]`
`[assignee: rally master]`
`[due: rally kickoff]`

0

## Background

`[id: background]`
`[description: What has been done before? What are the deficiencies that are prompting the primary objective in this rally?]`
`[content_type: single paragraph or bullet list]`
`[required: true]`
`[assignee: rally master]`
`[due: rally kickoff]`

Provide background text here...

## Background Detail

`[id: bg_detail]`
`[description: Provide additional detail such as text, bullet points, and/or links to figures stored on OSF that capture more detail about the background.]`
`[content_type: sections]`
`[required: true]`
`[assignee: rally master or domain expert]`
`[due: end of rally]`

#### Background Section 1 Title

Content...

#### Background Section 2 Title

- item 1
- item 2

#### Background Section 3 Title

Figure:
- {OSF link to hi-res png image (e.g. https://osf.io/xxxxx/)}
- {Informative title}
- {Explanation of why figure is important / takehome message about the figure}

## Motivation

`[id: motivation]`
`[description: What is the context for this rally and why is this rally expected to be important? Elaborate on the primary use case from the Problem Statement.]`
`[content_type: single paragraph]`
`[required: true]`
`[assignee: rally master]`
`[due: rally kickoff]`

Provide rally motivation text here...

## Deliverables

`[id: deliverables]`
`[description: In addition to the final data story, what other deliverables are planned?  This may be an algorithm, a publication manuscript, a Grand Challenges presentation, etc.]`
`[content_type: bullet list]`
`[required: true]`
`[assignee: rally master]`
`[due: rally kickoff]`

- deliverable 1
- deliverable 2

## Is Data Available

`[id: data_available]`
`[description: Is data available necessary to answering the questions - if not available, rally cannot begin.]`
`[content_type: yes/no]`
`[required: true]`
`[assignee: rally master]`
`[due: rally kickoff]`

Write either yes or no here.

## Dataset List

`[id: data_list]`
`[description: List the IDs of the studies used for this rally. You can find a list of the IDs (here)[http://bit.ly/hbgd-data].]`
`[content_type: comma separated]`
`[required: true]`
`[assignee: data scientist]`
`[due: rally kickoff]`

id1, id2, id3

## Data Description

`[id: data_desc]`
`[description: This allows for more description to help to understand the context of the datasets that will be used in the in analysis.]`
`[content_type: bullet list]`
`[required: true]`
`[assignee: data scientist]`
`[due: rally kickoff]`

- Data description text...
- Data description text...

## Outcome Variables

`[id: data_outcomes]`
`[description: What are the outcome variables in the datasets being used that we are interested in for this rally?]`
`[content_type: single paragraph or bullet list]`
`[required: true]`
`[assignee: data scientist]`
`[due: rally kickoff / update throughout]`

## Predictor Variables

`[id: data_predictors]`
`[description: List the predictor variables available in the data that will be used for the analysis.]`
`[content_type: bullet list]`
`[required: true]`
`[assignee: data scientist]`
`[due: rally kickoff / update throughout]`

- Variable 1 (optional description)
- Variable 2 (optional description)

## Methods

`[id: methods]`
`[description: A high-level one or two sentence description of the methods used in this rally.]`
`[content_type: single paragraph]`
`[required: true]`
`[assignee: data scientist]`
`[due: rally kickoff / update throughout]`

High-level methods text here...

## Methods Detail

`[id: methods_detail]`
`[description: Provide bullet points about additional methods detail, and/or links to figures stored on OSF that illustrate methods.]`
`[content_type: sections]`
`[required: true]`
`[assignee: data scientist]`
`[due: end of rally]`

#### Methods Section 1 Title

Content...

#### Methods Section 2 Title

- item 1
- item 2

#### Methods Section 3 Title

Figure:
- {OSF link to hi-res png image (e.g. https://osf.io/xxxxx/)}
- {Informative title}
- {Explanation of why figure is important / takehome message about the figure}

## GHAP Analysis Git Repo

`[id: analysis_repo]`
`[description: Provide a link to the git repository on GHAP where the code for this rally is housed.]`
`[content_type: single line]`
`[required: true]`
`[assignee: data scientist]`
`[due: end of rally]`

Link to git repo here...

## Key Finding(s)

`[id: findings]`
`[description: Key findings are the final result, why we should care about it, and what the potential for future transformation arises from the result and learning.]`
`[content_type: bullet list]`
`[required: true]`
`[assignee: data scientist]`
`[due: end of rally]`

- Finding 1.
- Finding 2.

## Results Detail

`[id: results_detail]`
`[description: Provide bullet points about additional results detail, and/or links to figures stored on OSF that illustrate results.]`
`[content_type: sections]`
`[required: true]`
`[assignee: data scientist]`
`[due: end of rally]`

#### Results Section 1 Title

Content...

#### Results Section 2 Title

- item 1
- item 2

#### Results Section 3 Title

Figure:
- {OSF link to hi-res png image (e.g. https://osf.io/xxxxx/)}
- {Informative title}
- {Explanation of why figure is important / takehome message about the figure}

#### Results Section 4 Title

Table:
- {OSF link to hi-res png image of the table (e.g. https://osf.io/xxxxx/)}
- {Informative title}
- {Explanation of why table is important / takehome message about the table}

## Value

`[id: value]`
`[description: What is the impact value of this work? What does it mean for day-to-day operations?.]`
`[content_type: single paragraph]`
`[required: true]`
`[assignee: data scientist / domain expert]`
`[due: end of rally]`

Statement about value of this work here...

## Next Steps

`[id: next_steps]`
`[description: Provide brief points on what is next; either further analysis needed, or how to begin to implement the findings into actionable knowledge.]`
`[content_type: bullet list]`
`[required: true]`
`[assignee: rally master or domain expert]`
`[due: end of rally]`

- Step 1
- Step 2

## To be Continued?

`[id: tbc]`
`[description: Is this rally to be continued? (yes/no).]`
`[content_type: yes/no]`
`[required: true]`
`[assignee: rally master]`
`[due: end of rally]`

Write either yes or no here.

## Working Group Member Assessment

`[id: wg_assess]`
`[description: What value did this rally generate? Is the result earth-shattering or ho-hum?]`
`[content_type: single paragraph]`
`[required: true]`
`[assignee: rally master or domain expert]`
`[due: end of rally]`

Assessment text here...

## Data Scientist Assessment

`[id: ds_assess]`
`[description: Fromt the data scientist's perspective, why did / didn't this rally succeed?]`
`[content_type: single paragraph]`
`[required: true]`
`[assignee: data scientist]`
`[due: end of rally]`

Assessment text here...

## Presenter

`[id: presenter]`
`[description: Name of person who will present the rally read-out (optional).]`
`[content_type: single line]`
`[required: false]`
`[assignee: rally master]`
`[due: end of rally]`

Person's Name

## Presentation OSF ID

`[id: presentation_id]`
`[description: The OSF ID of the final presentation uploaded to OSF. Generally it is placed in the 'rally-output' directory in the OSF component space.]`
`[content_type: OSF ID]`
`[required: true]`
`[assignee: rally master]`
`[due: end of rally]`

xxxxx
