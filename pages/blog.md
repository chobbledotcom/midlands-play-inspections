---
name: Blog
meta_title: Recent Site Updates and Inspection News
meta_description: Updates from Midland Play Inspections, recent inspection jobs
  across the Midlands and notes on bouncy castle safety testing.
permalink: /blog/
eleventyNavigation:
  key: Blog
  order: 4
blocks:
  - type: hero
    dark: false
    compact: false
    badge: Blog
    content: |-
      # What's new on the site

      A running log of what's changed here: new pages, new guides, and the odd job worth writing up once we've asked the people involved.
  - type: items
    dark: false
    compact: false
    collection: news
    horizontal: false
    masonry: false
    image_aspect_ratio: 4/3
  - type: cta
    dark: false
    compact: false
    content: |-
      ## Want your fleet on here?

      We're happy to link out to every hire company we test for. Get your inspection booked and we'll write the job up.
    button:
      text: Book an inspection
      href: /contact/
      variant: secondary
      size: lg
no_index: false
---
