\version "2.25.13"

\paper {
  ragged-right = ##f
  ragged-last-right = ##f
  tagline = ##f
}

\score {
  <<
  \new Staff \with { instrumentName = "Accordion" } { \clef "treble" s1 }

  >>
}

\layout {
  \context {
    \Score
    \omit TimeSignature

  }
}
