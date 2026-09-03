---
name: Blog
meta_title: Recent Site Updates
meta_description: A log of what has changed on the Midland Play Inspections
  site, from new pages and guides to notes on PIPA testing across the
  Midlands.
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
      # Recent site updates

      A running log of what has changed here, newest first: new pages, new guides, and the occasional bit of tidying behind the scenes. The longer explanations live in the guides.
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
      ## Here for an inspection rather than the site news?

      The rest of the site has the detail on what we check, how long it takes and what it costs. Bookings and questions go through the contact page.
    button:
      text: Book an inspection
      href: /contact/
      variant: secondary
      size: lg
no_index: false
---
