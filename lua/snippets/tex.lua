local ls = require('luasnip')
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local ps = ls.parser.parse_snippet
local fmta = require('luasnip.extras.fmt').fmta
local rep = require('luasnip.extras').rep

local ls_utils = require('utils.luasnip_utils')
local dyn_sel = ls_utils.dyn_sel

return {
  s({ trig = 'todo', desc = '\\todo{...}' }, fmta([[
    \todo{<>}
  ]], { dyn_sel(1, '...') })),

  s({ trig = 'todo:', desc = '\\todo{...}' }, fmta([[
    % TODO: <>
  ]], { dyn_sel(1, '...') })),

  s({ trig = 'up', desc = '\\usepackage{...}' }, fmta([[
    \usepackage<>{<>}
  ]], {
    c(1, { sn(nil, { t('['), i(1), t(']') }), t('') }),
    dyn_sel(2, '...'),
  })),

  s({ trig = 'enum', desc = 'enumerate block' }, fmta([[
    \begin{enumerate}
      \item <>
    \end{enumerate}
  ]], { dyn_sel(1) }, { indent_string = '  ' })),

  s({ trig = 'item', desc = 'itemize block', priority = 1000 }, fmta([[
    \begin{itemize}
      \item <>
    \end{itemize}
  ]], { dyn_sel(1) }, { indent_string = '  ' })),

  s({ trig = 'i', desc = '\\item ...', priority = 99 }, fmta([[
    \item <>
  ]], { dyn_sel(1) })),

  s({ trig = 'big(' }, fmta('\\big( <> \\big)', { dyn_sel(1) })),
  s({ trig = 'big[' }, fmta('\\big[ <> \\big]', { dyn_sel(1) })),
  s({ trig = 'big{' }, fmta('\\big\\{ <> \\big\\}', { dyn_sel(1) })),
  s({ trig = 'Big(' }, fmta('\\Big( <> \\Big)', { dyn_sel(1) })),
  s({ trig = 'Big[' }, fmta('\\Big[ <> \\Big]', { dyn_sel(1) })),
  s({ trig = 'Big{' }, fmta('\\Big\\{ <> \\Big\\}', { dyn_sel(1) })),

  s({ trig = 'lr(' }, fmta('\\left( <> \\right)', { dyn_sel(1) })),
  s({ trig = 'lr[' }, fmta('\\left[ <> \\right]', { dyn_sel(1) })),
  s({ trig = 'lr{' }, fmta('\\left\\{ <> \\right\\}', { dyn_sel(1) })),
  s({ trig = 'lr<' }, fmta('\\langle <> \\rangle', { dyn_sel(1) })),

  s({ trig = 'fr', desc = '\\frac{}{}' }, fmta('\\frac{<>}{<>}', {
    dyn_sel(1), i(2)
  })),
  ps('pd', [[\frac{\partial $1}{\partial $2}]]),
  s({ trig = 'tfr', desc = '\\tfrac{}{}' }, fmta('\\tfrac{<>}{<>}', {
    dyn_sel(1), i(2)
  })),

  s({ trig = 'b', desc = 'begin-end block', priority = 1000 }, fmta([[
    \begin{<>}
      <>
    \end{<>}
  ]], { i(1), dyn_sel(2), rep(1) }, { indent_string = '  ' })),

  s({ trig = 'eq', desc = 'Equation', priority = 1000 }, fmta([[
    \begin{equation}\label{eq:<>}
      <>
    \end{equation}
  ]], { i(1, 'name'), dyn_sel(2) }, { indent_string = '  ' })),

  s({ trig = 'eq*', desc = 'Equation', priority = 1001 }, fmta([[
    \begin{equation*}
      <>
    \end{equation*}
  ]], { dyn_sel(1) }, { indent_string = '  ' })),

  s({ trig = 'subeq', desc = 'subequations' }, fmta([[
    \begin{subequations}\label{eq:<>}
      \begin{align}
        \label{eq:<>_<>}
        <>
      \end{align}
    \end{subequations}
  ]], {
    i(1, 'TODO'),
    rep(1),
    i(2, 'TODO'),
    dyn_sel(3),
  }, { indent_string = '  ' })),

  s({ trig = 'ali', desc = '\\begin{align(ed)}' }, fmta([[
    \begin{align<>}
      <>
    \end{align<>}
  ]], { i(1, 'ed'), dyn_sel(2), rep(1) }, { indent_string = '  ' })),

  s({ trig = 'cha', desc = 'Chapter' }, fmta([[
    \chapter{<>}
  ]], { dyn_sel(1, 'Chapter Name') })),

  s({ trig = 'sec', desc = 'Section' }, fmta([[
    \section{<>}
  ]], { dyn_sel(1, 'Section Name') })),

  s({ trig = 'sub', desc = 'Subsection' }, fmta([[
    \subsection{<>}
  ]], { dyn_sel(1, 'Subsection Name') })),

  s({ trig = 'ssub', desc = 'Subsubsection' }, fmta([[
    \subsubsection{<>}
  ]], { dyn_sel(1, 'Subsubsection Name') })),

  s({ trig = 'sub*', desc = 'Subsection w/o number' }, fmta([[
    \subsection*{<>}
  ]], { dyn_sel(1) })),

  s({ trig = 'ssub*', desc = 'Subsubsection w/o number' }, fmta([[
    \subsubsection*{<>}
  ]], { dyn_sel(1) })),

  s({ trig = 'par', desc = 'Paragraph head' }, fmta([[
    \paragraph{<>}
  ]], { dyn_sel(1) })),

  s({ trig = 'frame', desc = 'beamer frame' }, fmta([[
    \begin{frame}\frametitle{<>} % {{{2
      <>
    \end{frame}
    %\endinput % skip the remainder of this file
  ]], { i(1, 'title'), dyn_sel(2, 'content') }, { indent_string = '  ' })),

  s({ trig = 'tikz', desc = 'TikZ picture' }, fmta([[
    \begin{tikzpicture}[remember picture,overlay]
      \node[xshift=0em,yshift=0em,anchor=south west] at (current page.south west) {
        <>
      };
    \end{tikzpicture}
  ]], { dyn_sel(1, '...') }, { indent_string = '  ' })),

  s({ trig = 'cols', desc = 'columns (beamer)' }, fmta([[
    \begin{columns}
      \column{0.5\textwidth}
        <>
      \column{0.5\textwidth}
    \end{columns}
  ]], { dyn_sel(1, 'content') }, { indent_string = '  ' })),

  s({ trig = 'def', desc = 'Definition' }, fmta([[
    \begin{defn}[<>]\label{def:<>}
      <>
    \end{defn}
  ]], {
    i(1, 'Item'),
    i(2, 'todo'),
    dyn_sel(3, '...'),
  }, { indent_string = '  ' })),

  s({ trig = 'thm', desc = 'Theorem' }, fmta([[
    \begin{thm}[<>]\label{thm:<>}
      <>
    \end{thm}
  ]], {
    i(1, 'Item'),
    i(2, 'todo'),
    dyn_sel(3, '...'),
  }, { indent_string = '  ' })),

  s({ trig = 'rem', desc = 'Remark' }, fmta([[
    \begin{rem}
      <>
    \end{rem}
  ]], { dyn_sel(1, '...') }, { indent_string = '  ' })),

  ps('oo', [[\infty$0]]),
  ps('ref', [[\ref{$1}]]),
  ps('sref', [[Sec.~\ref{sec:$1}$0]]),
  ps('ssref', [[Sec.~\ref{sub:$1}$0]]),
  ps('eqref', [[Eq.~\eqref{eq:$1}]]),
  ps('eref', [[\eqref{eq:$1}]]),
  ps('fref', [[Fig.~\ref{fig:$1}]]),
  ps('tref', [[Tab.~\ref{tab:$1}]]),
  ps('cite', [[\\cite{$1}$0]]),
  ps('l', [[\label{$1}$0]]),

  s({ trig = 'Proc', desc = 'Pseudocode procedure' }, fmta([[
    \Procedure{<>}{<>}
      <>
    \EndProcedure
  ]], {
    i(1, 'Name'),
    i(2, 'args'),
    dyn_sel(3, [[\State]]),
  }, { indent_string = '  ' })),

  s({ trig = 'St', desc = 'Pseudocode statement' }, fmta([[
    \State <>
  ]], { dyn_sel(1, '...') })),

  s({ trig = 'Ret', desc = 'Pseudocode return' }, fmta([[
    \State \Return <>
  ]], { dyn_sel(1, '...') })),

  s({ trig = 'gets', desc = 'Pseudocode assignment' }, fmta([[
    \State <> $\gets$ <>
  ]], { i(1, '$x$'), dyn_sel(2, 'something') })),

  s({ trig = 'If', desc = 'Pseudocode if-endif' }, fmta([[
    \If{<>}
      <>
    \EndIf
  ]], { i(1), dyn_sel(2, [[\State]]) }, { indent_string = '  ' })),

  s({ trig = 'For', desc = 'Pseudocode for-loop' }, fmta([[
    <>
      <>
    \EndFor
  ]], {
    c(1, {
      sn(nil, {
        t([[\For{$]]),
        i(1, [[i \gets 1 \text{to} 10]]),
        t('$}'),
      }),
      sn(nil, { t([[\ForAll{$]]), i(1, [[x \in X]]), t('$}') }),
    }),
    dyn_sel(2, [[\State]]),
  }, { indent_string = '  ' })),

  ps('Cont', [[\State {\bfseries continue}$0]]),
  ps('Break', [[\State {\bfseries break}$0]]),

}
