# AGENTS.md - AI Assistant Guide for Midland Play Inspections

This is the single source of truth for any agent (Claude, Codex, whoever) working
in this repo. It covers the business, project architecture, coding style, content
voice, trust credentials, and the working process for refining pages.

## The Business

**Midland Play Inspections** is an inflatable inspection business run by **Luke**
from Lighthorne Heath, just outside Leamington Spa in Warwickshire. It carries out
annual PIPA and RPII inspections to BS EN 14960-1:2019 on bouncy castles, slides,
obstacle courses, disco domes, soft play, ball pools and non ride-on inflatable
games, travelling to the customer across the Midlands.

The angle that makes this business different from every other inspector is that
Luke has been on the other side of the clipboard since 2011. He runs
**[Best Party Hire](https://www.bestpartyhire.com/)**, a family bouncy castle and
party hire business covering Leamington, Warwick, Kenilworth, Southam and the
villages round about, set up in 2011 by Luke, his wife Louise and their children.
He has spent fifteen years booking inspections round a season that does not stop,
and being asked for tags by venues, schools and councils.

Customers are:

1. **Hire companies** wanting an annual inspection or a fleet day.
2. **Schools, nurseries, village halls, holiday parks and councils** who own their
   own soft play or inflatables and need a report for the health and safety file.
3. **New buyers and importers** needing an initial inspection before a unit earns
   anything.

This is a working inspector, not an inspection body with a head office. Content
should read like someone who does the job, and the site should not claim scale,
staff or accreditations that a one-person business does not have. See the
"Trust & credentials brief" section before writing any copy that touches
qualifications, insurance, prices or standards.

## Project Architecture

This is a **Chobble Client** site: a content repository that merges with the
[Chobble Template](https://github.com/chobbledotcom/chobble-template) at build
time to produce a static Eleventy site. It uses **Bun** as the package manager
and runtime.

This repo (`midlands-play-inspections`) holds:

- Site content (pages, news posts, images)
- Site configuration (`_data/`), custom styles (`css/theme.scss`), template
  overrides (`_includes/`)
- Build scripts and tooling (`scripts/`)

The Chobble Template holds:

- Eleventy config, layouts, collections, the design system and its blocks

At build time the two are merged into `.build/dev`, then Eleventy runs. The
template's markdown is deleted first, so content in this repo replaces the
template's example content rather than sitting alongside it.

**The template is pinned.** `chobble-template/` is a git submodule fixed to a
specific commit, and `scripts/prepare-dev.js` prefers it over cloning. To move to
a newer template, check the submodule out at the new commit, run a full build,
regenerate `.pages.yml` (see below), then commit the submodule bump with the
build fixes it needed.

### The design system, and how pages are built

Pages do not have a body. **Every page expresses all of its content as blocks in
YAML frontmatter**, and the base layout renders them. A page with markdown after
the closing `---` fails the build with "uses base.html but has body content".

```yaml
---
name: Pricing
meta_title: Inflatable Inspection Prices
meta_description: Guide prices for PIPA testing and RPII inspections.
eleventyNavigation:
  key: Pricing
  order: 3
blocks:
  - type: hero
    badge: Prices
    content: |
      # What an inspection costs
  - type: features
    intro_content: |
      ## Included in every inspection
    items:
      - icon: "hugeicons:tag-01"
        name: PIPA tag
        description: Fitted and registered, no extra charge.
---
```

**`chobble-template/BLOCKS_LAYOUT.md` is the reference for every block type and
every parameter.** Read it before adding a block you have not used. Do not guess
parameter names; a wrong one fails silently and renders nothing.

Blocks used on this site: `hero`, `features`, `stats`, `section-header`,
`split-callout`, `split-icon-links`, `split-html`, `split-full`, `cta`,
`callout`, `faqs`, `icon-links`, `contact-form`, `markdown`, `gallery`, `items`,
`include`, `news-meta`.

The sitewide pre-footer band comes from `snippets/footer-content.md`. The base
layout renders that snippet's blocks at the end of every page, so anything added
there appears site-wide.

Notes worth knowing:

- Sections alternate background colours automatically. Do not try to control this
  from a block.
- `dark: true` on a block inverts that section to the brand navy.
- Blocks animate in on scroll via `data-reveal`. Screenshots must run with
  reduced motion or half the page renders blank (see "Screenshotting").
- **`features` grids must hold a multiple of three items, and six is the right
  answer nearly every time.** The grid is `repeat(auto-fit, minmax(280px, 1fr))`
  inside a 1200px container, so it lays out three across on desktop, two on
  tablet and one on mobile. Six divides cleanly into all three; four leaves an
  orphan card sitting on its own row. If you cannot find a sixth item worth
  writing, the block wants three, not four or five.
- Headings flip to white in dark, CTA and coloured panels via `--color-heading`
  in `css/theme.scss`. If a new coloured panel type appears with navy headings on
  a dark background, add its selector to that list.

### Icons

Icons are [Iconify](https://icon-sets.iconify.design/) IDs such as
`"hugeicons:tag-01"`. The template fetches them at build time and caches them to
`assets/icons/iconify/`, but **Bun's `fetch` cannot reach the Iconify API through
the agent proxy**, so the build fails on an uncached icon.

Always run this after adding or changing any icon:

```bash
./scripts/fetch-icons.sh
```

It scans `pages/` and `_includes/` for icon IDs, downloads anything missing with
curl, and fails loudly on an ID that does not exist. The cached SVGs are
committed. Check a name exists before using it; a lot of plausible-sounding
hugeicons names (`disco-01`, `slide-01`) do not.

---

## Quick Reference

### Essential Commands

```bash
bun install              # Install dependencies (MUST use bun, not npm)
bun run build            # Merge template + content, build to _site/
bun run serve            # Development server with hot reload
bun run prepare-dev      # Merge template and content without building
bun run test             # Run tests
bun run lint             # Check scripts/ with Biome
bun run lint:fix         # Auto-fix lint issues in scripts/
bun run cpd              # Copy-paste detection on scripts/
./scripts/fetch-icons.sh # Cache any newly-referenced Iconify icons
```

`bun run build` fails the whole build on a broken internal link, so a link to a
page that does not exist yet will stop you. Write the target page or drop the
link.

### Directory Structure

```
midlands-play-inspections/
├── pages/             # Every static page, as blocks in frontmatter
├── news/              # Job write-ups, YYYY-MM-DD-slug.md
├── snippets/          # footer-content.md renders on every page
├── _data/             # site.json, meta.json, config.json, strings.json
├── _includes/         # Overrides of template includes
├── css/theme.scss     # Brand colours, fonts and component overrides
├── images/            # Site images, including images/news/ job photos
├── assets/fonts/      # Self-hosted Montserrat
├── assets/favicon/    # Favicons, copied to the site root at build
├── assets/icons/      # Cached Iconify SVGs
├── brand/             # Logo artwork and brand guidelines PDF (NOT published)
├── scripts/           # Build utilities
├── chobble-template/  # Pinned template submodule
├── .pages.yml         # CMS content model (GENERATED, see below)
├── AGENTS.md          # This file
└── CLAUDE.md          # One-line pointer to this file
```

`brand/` is deliberately outside `assets/`. Anything in `assets/` or `images/` is
passthrough-copied to the live site, and the brand guidelines PDF should not be.

### Key Data Files

| File | Purpose |
|------|---------|
| `_data/site.json` | Site name, URL, socials, opening times, and the generated `cms_config` |
| `_data/config.json` | Feature flags. Cart and quote modes are off; `placeholder_images` is off, so every collection item needs a real `thumbnail` |
| `_data/meta.json` | Organisation JSON-LD (address, phone, founder) |
| `_data/strings.json` | Overrides template strings. Renames the news collection to "Recent Jobs" at `/recent-jobs/` |
| `_includes/head-scripts.html` | Favicon and theme-colour tags |
| `_includes/navigation-start.html` | Logo and name lock-up in the header |
| `_includes/news-post-header.html` | Override so the post header says "Recent Jobs", not "News" |

### `.pages.yml` is generated, not hand-written

`.pages.yml` is the CMS content model. **Do not edit it by hand**, because the
next regeneration will silently throw the edit away. It is generated from
`cms_config` in `_data/site.json` by the template's `customise-cms` script.

To regenerate after changing collections or bumping the template:

```bash
bun run prepare-dev
cd .build/dev
bun scripts/customise-cms/index.js \
  --collections pages,news,snippets \
  --enable permalinks,faqs,galleries,no_index,use_visual_editor \
  --disable redirects,features,add_ons,external_navigation_urls,\
external_purchases,event_locations_and_dates,parent_categories
```

Then copy `.build/dev/.pages.yml` back to the repo root with every `src/`
stripped out, and copy the `cms_config` key from `.build/dev/src/_data/site.json`
back into `_data/site.json`. `bun run update-pages` does this automatically but
uses Bun's `fetch`, which the agent proxy blocks.

Only `pages`, `news` and `snippets` are enabled. If you add a collection, enable
it here as well or it will not appear in the CMS.

### Screenshotting

Chromium is at `/opt/pw-browsers/chromium` and Playwright is configured to find
it. Do not run `playwright install`.

Serve `_site/` and screenshot with **`reducedMotion: "reduce"`** set on the
browser context. Without it, `data-reveal` blocks stay invisible and most of the
page screenshots blank.

```js
const ctx = await browser.newContext({
  viewport: { width: 1440, height: 1000 },
  deviceScaleFactor: 2,
  reducedMotion: "reduce",
});
```

Check both 1440px and 390px. The header, the split blocks and the feature grids
all change shape at the `md` breakpoint.

---

## Owner-Confirmation Backlog

The live list of things Luke needs to confirm or supply. **Check here before
asking, and add to it rather than inventing an answer.** Everything below was
drafted from market research and needs his sign-off before the site goes live.

### Credentials, and the ones the site currently asserts

- **RPII registration.** The site says "RPII registered" and "registered
  inflatable inspector" in several places. Confirm Luke's registration is
  current, and get the registration number so it can go on the site and be
  checked at playinspectors.com. **If he is not yet registered, this wording has
  to come off the site before it goes live.**
- **PIPA registration.** The site says qualifying units get a PIPA tag and a
  report on the PIPA database. That requires being a registered PIPA inspector.
  Confirm, and get the inspector number.
- **Public liability / professional indemnity insurance.** Not currently
  mentioned anywhere. Most competitors lead with it. Get the insurer and the
  cover figure and add it.
- **Business status.** Sole trader or limited company, VAT registered or not, and
  the trading address to publish. `_data/meta.json` currently carries the Best
  Party Hire address at Lighthorne Heath.

### Contact details

- **The contact form does not work yet.** `/contact/` renders a "Contact Form
  Not Configured" panel. `_data/config.json` has `formspark_id` and
  `botpoison_public_key` set to `null`, and the shared build workflow swaps them
  for the `FORMSPARK_ID` and `BOTPOISON_PUBLIC_KEY` repository secrets. **Those
  secrets have to be set on the repo before launch**, or the panel goes live.
- **Email.** The site uses `luke@midlandplayinspections.co.uk`. Confirm the
  domain and mailbox exist.
- **Phone.** The site uses 07761 907 472, which is the published Best Party Hire
  number. Confirm whether the inspection business should use the same number or a
  separate one.
- **Opening times.** `_data/site.json` says Mon-Fri 8am-6pm, Sat 9am-1pm. Drafted,
  not confirmed.
- **Socials.** All null in `site.json`. Add any that exist.

### Pricing

Every figure on `/pricing/` is drafted from published competitor pricing, not from
Luke. He needs to set all of them before launch:

- Per-unit prices from £55 to £115
- The £545 fleet day rate
- Free travel across Warwickshire and the West Midlands
- £3 per additional PAT test
- Whether a re-check after a repair is free

### Services we have described but not confirmed

- **Repairs.** `/faqs/` now says "we inspect, we don't repair", that we will
  point you at a repairer, and that the re-check after a repair is usually free.
  Most competitors do repairs on site with a mobile sewing machine, so this is a
  real positioning decision. Confirm it is the one Luke wants.
- **Initial inspections on imported units.** `/inflatable-testing/` offers to
  look at photographs of an imported unit and say what we expect to find.
  Confirm he is happy to do that unpaid.
- **Operations manuals.** `/faqs/` says one "can be put together" for a unit
  whose manufacturer has gone. Confirm whether Luke does this himself, or is
  referring people elsewhere.
- **Turnaround.** Several pages say the report arrives "within a few days".
  Confirm what he will actually commit to.

### Content and assets

- **Real job photos.** `images/news/job-photo-*.svg` are placeholders that say
  PLACEHOLDER across them. Replace with real photos and delete the SVGs.
- **Naming inspection customers.** The example job posts describe customers
  generically ("a hire company just outside Coventry"). Ask permission and name
  them, with a link to their site, which is the whole point of the reciprocal
  link (see "Writing a job post").
- **Coverage claims.** `/areas-we-cover/` claims free travel across Warwickshire
  and the West Midlands, six days a week in season, and national travel for fleet
  days. Confirm.
- **"We" or "I".** The site is written in "we" throughout, on the basis that
  there is a family business behind it. If Luke would rather it read as one
  person, the whole site needs a pass. Ask him.

---

## Voice & tone

This site has a distinct voice: dry, plain-spoken, sceptical of marketing-speak,
recognisably Midlands without dialect cosplay. It is how Luke might write about
his own work, not how a copywriter would write it for him.

This is a guide, not a template. Slavish application is what makes copy sound
generated.

### The trap to avoid

The source corpus below is people **talking** or **writing plainly**, working
from their own context. Their patterns work because they are not trying to sell
you anything. Lift those patterns straight into website copy and you have turned
plain observation into ad copy. You can hear the agency.

The Warwickshire-ness in this site should come from **content** (real places,
real units, real specifics) and **word choice** (the kit, a few quid, in good
order, first time of asking, round our way), not from sentence structure or
affected accent.

#### The WhatsApp test

Read the line out loud. Could Luke type it on his phone between two jobs? If it
has a copywriter's structure (a punchy fragment, a parallel-list closer, a
one-line summary that "lands"), no, he would not. Take the polish off.

### Source corpus

Do not lean on any single voice; that becomes a tribute act. The shared DNA
across these is what we are after:

- **Philip Larkin** - born in Coventry. Plain, exact, unsentimental, never
  reaching for an effect. The closest thing there is to a native voice for this
  patch, and the best model for describing something ordinary accurately.
- **George Eliot** - Mary Ann Evans, born at Arbury just outside Nuneaton, a few
  miles from where Luke works. *Middlemarch* is provincial Warwickshire life
  observed without condescension, which is the register we want when writing
  about village halls and school fetes.
- **Alan Sillitoe** - Nottingham. *Saturday Night and Sunday Morning*. Plain
  Midlands working speech, no romance about the work and no apology for it.
- **Sue Townsend** - Leicester. The Adrian Mole books. Dry, deflating, funny
  without ever going for the joke.
- **Terry Hall and The Specials** - Coventry. Flat, deadpan, unshowy delivery.
  Worth listening to for how little emphasis a line needs.
- **Benjamin Zephaniah** - Handsworth, Birmingham. Direct, plain, unpretentious.
- **George Orwell** - the essays, especially "Politics and the English Language".
  English plain prose at its best, and the standing argument against every
  inflated phrase.

When stuck, do not generate. Read one of these. But remember they are people
writing in their own voice; do not import their punchlines.

#### Anti-corpus (the voices we are avoiding)

- **Alan Partridge** - Norwich small-businessman trying to sound polished. The
  voice we are satirising every time we resist its temptations.
- **David Brent** - Slough small-businessman trying to sound inspirational.
- **Del Boy Trotter** - Peckham salesman. Same trap, more cockney.
- **Captain Mainwaring** - small-town pomposity dressed up in modest words.

If a sentence sounds like Partridge, Brent, Del Boy or Mainwaring, it is wrong.

### Principles

#### 1. "We" throughout

"We have been hiring inflatables out round Warwickshire since 2011" is more
honest than "Midland Play Inspections was established by an operator with over a
decade of industry experience".

Switching to Luke by name is fine when it earns its place ("Luke runs both"). Do
not do it just to dress up a sentence. See the Owner-Confirmation Backlog on
whether "we" is the right call at all.

#### 2. Specifics over abstractions

CV33 not "the Midlands". Lighthorne Heath not "our base". The A46 not "the main
road". A worn anchor patch on the back left corner, not "minor wear". BS EN
14960-1:2019 not "the relevant standard". Nine units in a day, not "a full
fleet". The voice gets its credibility from being specific.

#### 3. Plain word choice

"A few quid" not "significant cost". "The kit" not "our equipment range". "We
come to you" not "mobile inspection services are provided". "We have been doing
this a while" not "with extensive industry experience". Trade vocabulary where it
fits. If we would not say it standing in a barn full of castles, we do not write
it.

#### 4. Looseness over polish

Long sentences with sub-clauses. Hedges ("about as many as you can do properly",
"give or take"). Asides in the middle of a thought. Sometimes a paragraph just
stops because there is nothing else to say. The voice gets its texture from
looseness, not from rhythm.

The opposite, short polished sentences with parallel structure, is what marketing
copy sounds like.

#### 5. Complete sentences, no punchline closers

The voice does not use sentence fragments. Every sentence has a subject and a
verb. Fragments masquerading as sentences ("Same-day quotes." / "No fuss." /
"Four steps, no paperwork games.") do not belong in the house voice, even when
they sound emphatic or efficient. They are a copywriter's tic.

This applies anywhere in the copy, not just at paragraph ends. Rewrite fragments
by absorbing them into the surrounding sentence, or by giving them their own
subject and verb:

- Bad: "Tags on, reports out the same week."
- Good: "The tags went on before we left and the reports went out the same week."

Even grammatically-complete sentences should not be used as cinematic punchline
closers ("And that is how Midland Play Inspections started."). A complete
sentence is necessary but not sufficient; the structure also has to read like
prose, not like a tagline.

Specific patterns to avoid:

- Single-word or fragment closers: "Sorted." / "No fuss." / "The lot."
- Multi-fragment summaries: "£80 a unit. Same-day quotes. Tags fitted on site."
- Cinematic one-line summaries: "That is how we have worked ever since."
- Lists of three where the third item is comic or undercutting.
- The X / X / X - Y structure: "Not a call centre, not a booking system, not a
  chatbot, just Luke."
- The "and yes, it works in a village hall" handle-the-objection move.

Headings, badges, button labels and bullet points are exempt; they are not
sentences. Block fields such as `figure_subtitle`, `badge` and stat `label` are
labels, not prose.

#### 6. Trust the reader

Do not explain the joke. Do not justify the claim. Do not repeat yourself. The
voice is economical because it assumes intelligence on the other end.

#### 7. Never adversarial towards the customer

The people we write about are hire operators, school business managers and
village hall committees, and they are who we work for. Copy should never cast
them as cutting corners, chancing it, or in need of policing.

There is a live temptation here that a hire site does not have: this is a safety
business, and safety copy slides very easily into "unlike the cowboys". Do not
write it. "If you hire inflatables out for money, they have to be inspected" is
a fact and it is fine. "Some operators would rather you did not know that" is
scaremongering about competitors and does not go on the site.

Where a genuine failure is worth describing, let the fault do the work rather
than the customer. "One of the toddler castles came up with a worn anchor patch"
is honest and fine. "They had not noticed it, of course" is not.

#### 8. Never use em-dashes

Em-dashes have been normalised out of this codebase. Use spaced hyphens, commas
or full stops where an em-dash was doing rhetorical work.

The reason: em-dashes are one of the strongest tells of generated copy. Real
plain-spoken writing uses commas, full stops and the occasional spaced hyphen.

Check before committing:

```bash
grep -rn "—\|&mdash;\|&#8212;" pages/ news/ _data/ _includes/ css/
```

That should return nothing. Check the entity forms too, because a `&mdash;`
inside a `split-html` block's `figure_html` renders as an em-dash and a plain
grep will not see it.

### Phrase pool (sparingly)

Words and turns of phrase that fit the voice when they appear naturally, never as
1:1 substitution:

- "a few quid"
- "the kit"
- "round our way" / "round here"
- "in good order"
- "give or take"
- "first time of asking"
- "worth an ask"
- "no bother"
- "before the light goes"

One or two per page is plenty. Build this up as more copy gets written.

### No-go list

Avoid:

- "Cor blimey" / "guv'nor", Cockney parody
- "Lovely jubbly" / "cushty", Del Boy parody
- Cockney rhyming slang of any kind
- "Our kid" / "ay up" / "owt" / "nowt" / "mardy", imported or overdone northern
  and Black Country markers. Luke is in south Warwickshire, not Wolverhampton,
  and laying on Brummie markers is class tourism either way
- Phonetic accent spelling ("summat", "fella", "yow")
- "Marvellous" / "splendid" / "frightfully", RP parody
- "Salt of the earth" / "no nonsense" / "down-to-earth", clichés about ordinary
  English character that signal the writer is not ordinary
- "Cowboys" / "back garden operators" / "the bloke down the pub" as a way of
  describing other hire firms. See principle 7
- Bouncy-castle puns. No "bouncing back", no "castle in the air", none of it

These can appear inside quotation marks if a customer says them. They do not
belong in house voice.

### SEO: keywords come before voice

The purpose of rewriting copy is to improve it, not to lose search rankings.
Voice is a constraint on how keywords are expressed, not a reason to remove them.

**Before rewriting any page, note what it needs to rank for.** Diff against the
old copy and ask whether the terms people search for are still present. If not,
the rewrite has made things worse regardless of how well it reads.

#### What must survive every rewrite

**Meta descriptions** must contain, in plain language:

- The primary search term ("PIPA testing", "inflatable inspection", "bouncy
  castle inspection")
- Geographic coverage (the Midlands, and the named counties or towns where the
  page is about a place)
- Under 160 characters, and not a word-for-word repeat of the page title

**Body copy** must retain:

- The scheme and standard names people actually type: **PIPA**, **RPII**,
  **BS EN 14960**, **PAT testing**, **HSG175**. These are search terms as well as
  trust signals
- Equipment synonyms. Somebody searching "bouncy castle test", "inflatable
  inspection" and "PIPA tag renewal" wants the same thing. Cover the variants
- Place names. Coventry, Birmingham, Leamington, Rugby, Nuneaton, Solihull,
  Stratford, Worcester, Leicester, Northampton and the rest earn their place

#### What can change freely

The framing. "We provide comprehensive nationwide inspection solutions" becomes
"we come to you, anywhere across the Midlands, and further for a fleet day". Same
keywords, no marketing voice.

The structure. A bulleted "perfect for" list can become a plain paragraph. What
it cannot do is disappear.

The density. Repeating "PIPA testing" five times is stuffing. Twice or three
times, including the meta description and once near the top, is good practice.

### Where to use it

- Home, About, Recent Jobs, and the job posts
- Section intros and transitions
- Headings where SEO allows
- Link text and button labels

### Where NOT to use it

- The parts of `/faqs/` and `/inflatable-testing/` that state what the law
  requires or what a standard covers
- Contact details and form labels
- Prices, which are a table
- Anywhere ambiguity costs the customer money or clarity

Inconsistency between pages is fine. Different pages have different jobs.

### Voice anti-patterns

The specific failure modes of trying too hard:

- **Fragment "sentences"** anywhere in copy, not just at paragraph end
- **Cinematic one-liners** as closers
- **The deflating undercut** used as a pattern rather than once
- **The rule-of-three list** done earnestly
- **The handle-the-objection move**
- **Em-dashes**, in any position, for any reason
- **Tag questions on every paragraph**
- **Trying to be funny**. The voice is dry, not jokey. If a line gets a laugh,
  fine. If it is *for* the laugh, cut it
- **Generic "Midlands" markers as a substitute for voice**. Naming the A46 does
  not fix marketing-speak underneath
- **Safety-fear selling**. See principle 7

---

## Trust & credentials brief

This section exists to stop copy claiming more than the business can back. It is
deliberately short, because this is a new business and there is not much history
to draw on yet. **Everything in the "not yet established" list must not appear in
copy until it moves to the "established" list.**

### Established

| Fact | Source |
|------|--------|
| Luke has hired inflatables out since 2011 | Best Party Hire's own site and directory listings, family business set up 2011 by Luke, Louise and their children |
| Best Party Hire covers Leamington, Warwick, Kenilworth, Southam and surrounding villages | bestpartyhire.com |
| Best Party Hire advertises RPII-tested equipment, PAT-tested electronics and £5m public liability | bestpartyhire.com. **This is the hire business's insurance, not the inspection business's** |
| Base is Lighthorne Heath, Leamington Spa, CV33 9TN | Public directory listings for Best Party Hire |
| Inflatables hired out commercially need annual inspection by a competent person | HSE guidance HSG175; PIPA's own "Do inflatables need testing?" page |
| PIPA is one of two inspection schemes named in HSG175 | pipa.org.uk |
| PIPA tags are checkable on a public database | pipa.org.uk |
| BS EN 14960-1:2019 is the standard for inflatable play equipment | The standard itself, cited across the industry |
| RPII registers inspectors; registration is checkable at playinspectors.com | rpii.org.uk / playinspectors.com |
| Competitor per-unit prices run roughly £75-£175, with day rates around £550 | Published price lists from inflatablepipatesting.co.uk and elliottsbouncycastlehire.co.uk |

### Not yet established

Do not write these as fact until the Owner-Confirmation Backlog clears them:

- That Luke holds current RPII registration, or his number
- That he is a registered PIPA inspector able to issue tags
- Any insurance figure for the inspection business
- Any claim about how many inspections he has done, or for whom
- Any named inspection customer
- Any claim about turnaround times beyond what he agrees to
- VAT registration or company number

### Things worth being careful about

- **PIPA and RPII are different.** RPII registers the person, PIPA is the scheme
  for inflatable play. Do not use them interchangeably.
- **Annual inspection is a legal duty; a PIPA tag is not.** The duty comes from
  the Health and Safety at Work Act and PUWER, with the detail in HSG175. PIPA
  itself says it cannot give legal advice. Phrase it that way round.
- **HSE withdrew from the BSI committee for BS EN 14960-1:2019 in June 2026** and
  says its endorsement of that committee's standards can no longer be claimed.
  The inspection regime carries on unchanged, but do not write "HSE-approved
  standard" or "HSE-endorsed". "The standard we test to" is safe.
- **Do not name another inspector or hire firm as a comparison.** Naming a hire
  company as a customer, with permission, is fine and encouraged.

---

## Refining a page

### Goals

- **Balanced objective.** Serve conversion, search and accuracy roughly equally.
  None wins at the others' expense.
- **Verifiable facts only.** Every concrete claim traces to the Trust &
  credentials brief, a standard, a published source, or something Luke has
  confirmed. No invented figures, no invented customers, no "perfect for any
  occasion" filler.
- **Always include a CTA**, woven in naturally rather than bolted on.
- **Depth scales with what there is to say.** Do not pad.

### Process

1. Note what the page needs to rank for: primary term, geography, and the
   customer type it speaks to. Check the existing meta description.
2. Read `chobble-template/BLOCKS_LAYOUT.md` for any block you are about to add
   or change.
3. Read the Trust & credentials brief before writing anything about
   qualifications, insurance, the law or standards.
4. Write it in plain English first. Do not reach for the voice yet.
5. Read it aloud. Mark every sentence that sounds like a brochure.
6. Apply the WhatsApp test to each marked sentence. Usually the fix is to
   lengthen the sentence, add a hedge, or break up a too-neat structure.
7. Check every concrete claim against a source. Delete anything that does not
   trace.
8. Run the mechanical checks:
   - `grep -rn "—\|&mdash;" pages/ news/ css/` returns nothing
   - No unquoted YAML scalar contains a colon followed by a space. `meta_title`
     and `meta_description` are the usual casualties, and the build fails with
     "mapping values are not allowed here". Rephrase with a comma, or quote the
     whole value
   - No fragment sentences in prose (headings and labels are exempt)
   - Meta description under 160 characters, contains the primary term and the
     geography, and is not the title repeated
   - Every internal link points at a page that exists
9. `./scripts/fetch-icons.sh` if any icon changed.
10. `bun run build`, then screenshot at 1440px and 390px with reduced motion.
11. Look at the screenshots. Blocks that render blank, headings that vanish into
    a background, and grids that orphan a single item are all things you only
    catch by looking.

### FAQ blocks: only when they earn their place

Add a `faqs` block only if there are at least three genuinely specific questions
worth answering. Two tests before writing any Q&A:

- **Specificity test.** Does the answer say something specific to this page? If
  the same answer would fit any inspector's site, cut it.
- **Triviality test.** Would the answer go stale if a small business detail
  changed? Avoid FAQs that need updating across several pages when a price moves.

If fewer than three survive, skip the block. No boilerplate FAQs, ever.

---

## Area landing pages

`pages/bouncy-castle-inspections-<slug>.md` are local SEO landing pages, one per
place named on `/areas-we-cover/`. There are twenty-one: fifteen towns and six
wider-Midlands county groupings.

They are deliberately **not** in `eleventyNavigation`, because twenty-one items
in a dropdown is unusable. `/areas-we-cover/` is the hub that links to all of
them, via two `icon-links` blocks. Add a new area page to that hub or nothing
will link to it.

Every one shares the same block structure, and that is fine. What must **not**
be shared is the prose. The `hero` intro, the `split-callout` body and the "Who
books us in X" paragraph are hand-written per area, because twenty-one pages
carrying the same three paragraphs with the town name swapped is a doorway-page
pattern and Google treats it as one.

What makes an area page carry its weight:

- **Real geography.** The road we actually come in on, roughly how long it
  takes from Lighthorne Heath, the postcode districts, the villages round it.
- **Something true about that place's hire trade.** Coventry has the most
  operators. Halesowen is far enough that a single small unit is hard to
  justify. Bromsgrove storage tends to be farm buildings with low collar ties.
- **An honest note about travel.** Free inside Warwickshire and the West
  Midlands, quoted as one figure further out, and worth grouping or sharing.

Do not invent venues, customers or "we regularly test at" claims. Distances,
roads and postcodes are verifiable; a named local customer is not until Luke
says so.

---

## Writing a job post

Job posts live in `news/`, named `YYYY-MM-DD-slug.md`, and appear at
`/recent-jobs/`. They do three jobs: they show the work is real, they give the
site fresh pages worth indexing, and they carry reciprocal links out to the hire
companies whose fleets we test.

### Structure

```yaml
---
name: A full fleet day at Best Party Hire
subtitle: Warwickshire            # shows in the post header and on the card
meta_title: ...
meta_description: ...
thumbnail: /images/news/some-photo.jpg   # REQUIRED, see below
blocks:
  - type: include
    file: news-post-header.html
  - type: news-meta
  - type: markdown
    content: |
      What we went out to, what we found, what happened next.
  - type: gallery
    aspect_ratio: "4/3"
    items:
      - image: /images/news/some-photo.jpg
        caption: What is actually in the picture
  - type: split-callout
    subtitle: Who we tested for
    content: |
      ## Their business name

      A couple of honest sentences about what they hire out and where.
    button:
      text: Visit their site
      href: https://example.co.uk/
      variant: primary
    figure_icon: "hugeicons:castle-01"
    figure_name: Their business name
    figure_subtitle: What they do, where
    figure_variant: primary
---
```

### Rules

- **`thumbnail` is required.** `placeholder_images` is off in `config.json`, so a
  post without one fails the build. Point it at one of the post's own photos.
- **Every post ends with a reciprocal link block.** That is the point of the
  section. Link to the hire company whose fleet we tested, with permission, or to
  Best Party Hire where the post is about school or council equipment.
- **Name the customer only with their permission.** Otherwise describe them
  generically ("a hire company just outside Coventry") and say so in the Owner-
  Confirmation Backlog so Luke can go and ask.
- **Say something only the person who did the job would know.** The disco dome
  taking longest because of the netting. The van not getting within forty yards.
  A worn anchor patch on a specific corner. Without that the post is filler.
- **Do not turn a fault into a story about the customer.** See voice principle 7.
- **Captions describe what is in the picture**, factually, under 100 characters.
- Photos go in `images/news/`. The placeholder SVGs currently in there say
  PLACEHOLDER across the middle and are meant to be replaced and deleted.

---

## Functional Programming Style

The `scripts/` directory uses a functional approach with curried, composable
functions. This suits a static site generator, which is a series of transforms
with no mutable state:

```
Content Files → Parse → Transform → Filter → Sort → Render → Static HTML
```

Each step is a pure function. Data flows through pipelines without mutation.

### Import Aliases

Use the `#fp` alias for functional utilities:

```javascript
import { pipe, filter, map, unique } from "#fp";
import { memoize } from "#fp/memoize";
import { sortBy } from "#fp/sorting";
```

---

## Functional Utilities (`#fp`)

### Core Composition

| Function | Purpose | Example |
|----------|---------|---------|
| `pipe(...fns)` | Compose functions left-to-right | `pipe(filter(x), map(y))(arr)` |

### Curried Array Operations

| Function | Purpose | Example |
|----------|---------|---------|
| `filter(pred)` | Curried array filter | `filter(x => x > 0)(arr)` |
| `map(fn)` | Curried array map | `map(x => x * 2)(arr)` |
| `flatMap(fn)` | Curried array flatMap | `flatMap(x => [x, x])(arr)` |
| `reduce(fn, init)` | Curried array reduce | `reduce((a, x) => a + x, 0)(arr)` |
| `sort(cmp)` | Non-mutating sort | `sort((a, b) => a - b)(arr)` |
| `sortBy(key)` | Sort by property/getter | `sortBy('name')(users)` |

### Deduplication & Filtering

| Function | Purpose | Example |
|----------|---------|---------|
| `unique(arr)` | Remove duplicates | `unique([1, 1, 2])` → `[1, 2]` |
| `uniqueBy(fn)` | Dedupe by key | `uniqueBy(x => x.id)(arr)` |
| `compact(arr)` | Remove falsy values | `compact([1, null, 2])` → `[1, 2]` |
| `filterMap(pred, fn)` | Filter + map in one pass | `filterMap(x => x > 0, x => x * 2)(arr)` |

### Membership & Exclusion

| Function | Purpose | Example |
|----------|---------|---------|
| `memberOf(vals)` | Membership predicate | `filter(memberOf(['a', 'b']))(arr)` |
| `notMemberOf(vals)` | Exclusion predicate | `filter(notMemberOf(['x']))(arr)` |
| `exclude(vals)` | Filter out values | `exclude(['a'])(arr)` |
| `pick(keys)` | Extract object keys | `pick(['a', 'b'])(obj)` |

### Caching & Memoization

| Function | Purpose | Example |
|----------|---------|---------|
| `memoize(fn, opts?)` | Cache results | `memoize(fn, { cacheKey })` |
| `indexBy(getKey)` | Build cached lookup | `indexBy(x => x.id)(arr)` |
| `groupByWithCache(fn)` | Build cached grouping | `groupByWithCache(x => x.tags)(arr)` |

### Utilities

| Function | Purpose | Example |
|----------|---------|---------|
| `pluralize(s, p?)` | Format count | `pluralize('item')(3)` → `"3 items"` |
| `accumulate(fn)` | Safe array building in reduce | See below |

### Safe Array Building with `accumulate()`

Avoid the `noAccumulatingSpread` lint error:

```javascript
// BAD - O(n^2) performance
const ids = items.reduce((acc, item) =>
  item.id ? [...acc, item.id] : acc, []);

// GOOD - O(n) performance
import { accumulate } from "#fp";
const ids = accumulate((acc, item) => {
  if (item.id) acc.push(item.id);
  return acc;
})(items);
```

---

## Linting Rules (Biome)

Biome runs over `scripts/` only.

| Rule | Requirement |
|------|-------------|
| `useArrowFunction` | Use arrow functions |
| `useTemplate` | Use template literals |
| `useConst` | Use const (or let when reassignment needed) |
| `noVar` | Never use var |
| `noDoubleEquals` | Use `===`, not `==` |
| `noForEach` | Use `for...of` or curried `map`/`filter` |
| `noAccumulatingSpread` | Use `accumulate()` helper |
| `noUnusedImports` | Remove unused imports |
| `noUnusedVariables` | Remove unused variables |
| `noExcessiveCognitiveComplexity` | Max complexity: 7 (30 in tests) |
| `noConsole` | No console.log except in scripts/ |

Formatting is 2-space indentation. Run `bun run lint:fix` to auto-format.

---

## Anti-Patterns to Avoid

1. **Don't use npm.** This project requires Bun
2. **Don't put content in a page body.** Everything is a block in frontmatter
3. **Don't guess block parameters.** Read `chobble-template/BLOCKS_LAYOUT.md`
4. **Don't add an icon without running `./scripts/fetch-icons.sh`.** The build
   cannot reach the Iconify API
5. **Don't hand-edit `.pages.yml`.** It is generated
6. **Don't use em-dashes.** Anywhere
7. **Don't write fragment sentences** in prose
8. **Don't claim a credential** that is still in the Owner-Confirmation Backlog
9. **Don't screenshot without reduced motion.** Half the page will be blank
10. **Don't use `forEach`, `var` or `==`** in scripts
11. **Don't exceed complexity 7.** Break functions up
12. **Don't mutate data.** Create new objects and arrays

---

## When Making Changes

1. **Read existing code and copy first.** Understand the patterns before changing
   them
2. **Follow existing conventions.** Match the style of what is around it
3. **Run the linter.** `bun run lint:fix`
4. **Build before you finish.** `bun run build` catches broken links, missing
   images, bad block parameters and SCSS errors
5. **Look at the result.** Screenshot at both breakpoints with reduced motion

For content changes:

6. **Open "Refining a page"** for pages, or **"Writing a job post"** for `news/`
7. **Read the "Trust & credentials brief"** before any copy touching
   qualifications, safety, insurance, the law or prices
8. **Read "Voice & tone"** before writing any customer-facing prose. You have a
   tendency to ignore it
9. **Verify every claim against a source.** No invented figures, no invented
   customers, no filler
