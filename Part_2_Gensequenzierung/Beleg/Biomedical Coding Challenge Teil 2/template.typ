// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
// Go ahead and customize it to your liking!
#let project(title: "", authors: (), body) = {
  // Set the document's basic properties.
  set document(author: authors, title: title)
  set page(numbering: "1", number-align: center)
  set text(font: "Linux Libertine", lang: "de")
  set heading(numbering: "1.1")

  // Title row.
  align(center)[
    #block(text(weight: 700, 2.75em, title))
  ]

  // Author information.
  pad(
    top: 0.5em,
    bottom: 0.5em,
    x: 1em,
    grid(
      columns: (1fr,) * calc.min(3, authors.len()),
      gutter: 1em,
      ..authors.map(author => align(center, text(size: 1.75em)[#author])),
    ),
  )

  // Main body.
  set par(justify: true)

  body
}