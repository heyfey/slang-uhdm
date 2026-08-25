// r10uvm132 grid — THE MACRO DEFINITIONS, IN THEIR OWN FILE ON PURPOSE.
//
// Two arm-design traps inherited from r10uvm128repro/ARMS.r10uvm128.txt, both
// paid for there and both re-checked here:
//   * a macro DEFINED AND INVOKED IN ONE FILE reproduces the symptom through a
//     DIFFERENT mechanism, so every definition below lives here and every
//     invocation lives in an arm file;
//   * a body that begins on the `define line itself lands in
//     `macroInvLineCol`'s SINGLE-LINE regime, where our spans map to the
//     INVOCATION line and golden's to the DEFINITION line and no cell can
//     converge — so every body below begins on a CONTINUATION line.
//
// The law's own mechanism is the `` `` `` TOKEN PASTE in the nested invocation
// (`G132_QDA` / `G132_QDA2`); `G132_NEST` is the SAME nesting WITHOUT a paste
// and is a control, not a cell.

`define G132_QUEUE_RESIZE(ARG,VAL) \
  while(ARG.size()<sz132) ARG.push_back(VAL); \
  while(ARG.size()>sz132) void'(ARG.pop_front()); \

`define G132_QUEUE_TRIM(ARG,VAL) \
  ARG.delete(); \
  ARG.push_back(VAL); \

`define G132_QUEUE_USER(ARG,VAL) \
  ARG.g132_user(VAL); \

// PASTED inner-macro NAME — the law's shape (uvm_object_defines.svh:2009's
// `` `M_UVM_``TYPE``_RESIZE(ARG,"") ``).
`define G132_QDA(TYPE,ARG) \
  begin \
    int sz132 = 3; \
    `G132_``TYPE``_RESIZE(ARG,"") \
  end \

// PASTED with a SUFFIX and a different argument spelling.
`define G132_QDA2(TYPE,ARG,V) \
  begin \
    int sz132 = 1; \
    `G132_``TYPE``_TRIM(ARG,V) \
  end \

// PASTED, reaching a USER method rather than a built-in.
`define G132_QDAU(TYPE,ARG,V) \
  begin \
    `G132_``TYPE``_USER(ARG,V) \
  end \

// NESTED, NO PASTE — the control that reads back CORRECTLY.
`define G132_NEST(ARG) \
  begin \
    int sz132 = 3; \
    `G132_QUEUE_RESIZE(ARG,"") \
  end \

// SINGLE-LEVEL macro whose receiver IS the argument.
`define G132_ONE(ARG) \
  begin \
    int sz132 = 3; \
    while(ARG.size()<sz132) ARG.push_back(""); \
  end \

// The receiver is macro BODY TEXT, not an argument.
`define G132_BODY(UNUSED) \
  begin \
    int sz132 = 3; \
    while(qbody132.size()<sz132) qbody132.push_back(""); \
  end \

// ---- the NEGATIVE CONTROLS, all pasted so the law's other fences decide ----
// a SCOPED receiver.
`define G132_SCOPED_RESIZE(ARG,VAL) \
  pkg_f132::qpkg132.push_back(VAL); \

// (an ESCAPED-IDENTIFIER receiver written in a macro BODY is NOT here:
//  Surelog's preprocessor cannot carry `\name ` through a `\`-continued body
//  and rejects the file with three syntax errors, so no golden exists for it.
//  Arm F reaches that fence through a macro ARGUMENT instead, which Surelog
//  does compile.)

// a `this.` receiver.
`define G132_THIS_RESIZE(ARG,VAL) \
  this.ARG.push_back(VAL); \

// an INDEXED receiver.
`define G132_IDX_RESIZE(ARG,VAL) \
  ARG[0].push_back(VAL); \

// a DOTTED receiver through a class handle.
`define G132_DOT_RESIZE(ARG,VAL) \
  ARG.qi132.push_back(VAL); \

// (end of definitions — a trailing `\` at EOF makes Surelog report an
//  unexpected <EOF>; this comment terminates the last body.)
