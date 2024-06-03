\version "__LILYPOND_VERSION__"

#(set-default-paper-size "tabloidlandscape")
#(set-global-staff-size 18)

\paper {
  ragged-right = ##f
  ragged-last-right = ##f
  ragged-last-bottom = ##f
  ragged-bottom = ##f
  tagline = ##f
  padding = 0
  indent = 0
  right-margin = 0.25\in
  left-margin = 1.75\in
  top-margin = .25\in
  bottom-margin = .25\in
  system-separator-markup = \slashSeparator
}

\score {
  <<
  __GROUPS__
  >>
}

\layout {
  \context {
    \Score
    \omit TimeSignature
  }
}
