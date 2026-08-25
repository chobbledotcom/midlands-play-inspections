---
name: Recent Jobs
meta_title: Recent Inspection Jobs
meta_description: Photos and write-ups from recent inflatable inspections across the Midlands, showing who we tested for, what we found, and links to the hire companies we work with.
permalink: /recent-jobs/
eleventyNavigation:
  key: Recent Jobs
  order: 4
blocks:
  - type: hero
    badge: Recent work
    content: |
      # Jobs we've been out on

      This is a running log of the fleets we've tested, the odd interesting
      fault, and the hire companies we work with round the Midlands.

  - type: items
    collection: news
    image_aspect_ratio: "4/3"

  - type: cta
    content: |
      ## Want your fleet on here?

      We're happy to link out to every hire company we test for. Get your
      inspection booked and we'll write the job up.
    button:
      text: Book an inspection
      href: /contact/
      variant: secondary
      size: lg
---
