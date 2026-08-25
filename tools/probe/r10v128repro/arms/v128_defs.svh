// r10v128 — ADVERSARIAL macro definitions for § macroSplitRecvIsAstChain128.
// In their OWN file so the receiver's two halves really are two buffers.
// Bodies start on a CONTINUATION line (never on the `define line itself),
// which is the single-line macroInvLineCol regime the implementer's arm-design
// trap names.  Formals are 3 characters (`ARG`) and arguments 1..20, so no
// cell can agree by walking start+name.size().

// ---- V1: WHICH HANDLE HEADS THE DROPPED OPERAND --------------------------
`define V1_THIS(ARG) \
  if (ARG.size() != this.ARG.size()) rcv = 101; \
  rcv = rcv + 1;
`define V1_SUPER(ARG) \
  if (ARG.size() != super.ARG.size()) rcv = 102; \
  rcv = rcv + 1;
`define V1_STATIC(ARG) \
  if (ARG.size() != stat_v.ARG.size()) rcv = 103; \
  rcv = rcv + 1;
`define V1_PKGSCOPE(ARG) \
  if (ARG.size() != pkg_v128::gh.ARG.size()) rcv = 104; \
  rcv = rcv + 1;
`define V1_CLSSCOPE(ARG) \
  if (ARG.size() != cls_v128::stat_v.ARG.size()) rcv = 105; \
  rcv = rcv + 1;
`define V1_TWOHANDLE(ARG) \
  if (ARG.size() != h1_v.h2_v.ARG.size()) rcv = 106; \
  rcv = rcv + 1;
`define V1_ESCAPED(ARG) \
  if (ARG.size() != \esc$h .ARG.size()) rcv = 107; \
  rcv = rcv + 1;
`define V1_SAMEARGTWICE(ARG) \
  if (ARG.ARG.q.size() != 0) rcv = 108; \
  rcv = rcv + 1;
`define V1_INDEXED(ARG) \
  if (ARG.size() != harr_v[0].ARG.size()) rcv = 109; \
  rcv = rcv + 1;
`define V1_CALLRECV(ARG) \
  if (ARG.size() != get_h().ARG.size()) rcv = 110; \
  rcv = rcv + 1;
`define V1_THREELINK(ARG) \
  if (ARG.size() != h1_v.h2_v.h3_v.ARG.size()) rcv = 111; \
  rcv = rcv + 1;
`define V1_THISCHAIN(ARG) \
  if (ARG.size() != this.h1_v.ARG.size()) rcv = 112; \
  rcv = rcv + 1;

// ---- V2: PROPERTY KIND x BUILT-IN METHOD ---------------------------------
`define V2_SIZE(ARG) \
  if (ARG.size() != ob_v.ARG.size()) rcv = 201; \
  rcv = rcv + 1;
`define V2_NUM(ARG) \
  if (ARG.num() != ob_v.ARG.num()) rcv = 202; \
  rcv = rcv + 1;
`define V2_EXISTS(ARG) \
  if (ARG.exists("kk") != ob_v.ARG.exists("kk")) rcv = 203; \
  rcv = rcv + 1;
`define V2_DELETE(ARG) \
  ob_v.ARG.delete(); \
  rcv = rcv + 1;
`define V2_FIRST(ARG) \
  void'(ob_v.ARG.first(ky_v)); \
  rcv = rcv + 1;
`define V2_USER(ARG) \
  rcv = ob_v.ARG.user_m(); \
  rcv = rcv + 1;
`define V2_SCALARFLD(ARG) \
  rcv = ob_v.ARG; \
  rcv = rcv + 1;

// ---- V3: OPERATOR x OPERAND POSITION -------------------------------------
`define V3_BOTH(ARG) \
  if (ob_v.ARG.size() != oc_v.ARG.size()) rcv = 301; \
  rcv = rcv + 1;
`define V3_FIRST(ARG) \
  if (ob_v.ARG.size() != ARG.size()) rcv = 302; \
  rcv = rcv + 1;
`define V3_OR(ARG) \
  if (ARG.size() || ob_v.ARG.size()) rcv = 303; \
  rcv = rcv + 1;
`define V3_TERN(ARG) \
  rcv = (ob_v.ARG.size() > 2) ? ob_v.ARG.size() : 0; \
  rcv = rcv + 1;
`define V3_RETURN(ARG) \
  return ob_v.ARG.size();
`define V3_BARE(ARG) \
  ob_v.ARG.delete(); \
  rcv = rcv + 1;
`define V3_WHILECOND(ARG) \
  while (ob_v.ARG.size() > 77) rcv = 305; \
  rcv = rcv + 1;
`define V3_NESTED(ARG) \
  if ((ARG.size() + ob_v.ARG.size()) < (oc_v.ARG.size() * 2)) rcv = 306; \
  rcv = rcv + 1;

// ---- V4: HOMES + INSTANCE COUNTS -----------------------------------------
`define V4_CELL(ARG) \
  if (ARG.size() != ob_v.ARG.size()) rcv = 401; \
  rcv = rcv + 1;
`define V4_TWO(A1, A2) \
  if (A1.size() != ob_v.A2.size()) rcv = 402; \
  if (A2.size() != ob_v.A1.size()) rcv = 403; \
  rcv = rcv + 1;
`define V4_THREE(A1, A2, A3) \
  if (A1.size() != ob_v.A2.size()) rcv = 404; \
  if (A2.size() != ob_v.A3.size()) rcv = 405; \
  if (A3.size() != ob_v.A1.size()) rcv = 406; \
  rcv = rcv + 1;
// a macro whose body invokes ANOTHER macro (nested expansion buffers)
`define V4_INNER(ARG) \
  if (ARG.size() != ob_v.ARG.size()) rcv = 407;
`define V4_OUTER(ARG) \
  `V4_INNER(ARG) \
  rcv = rcv + 1;

// ---- V5: a HIERARCHICAL receiver (the leaf-name face of the AST chain) -----
`define V5_HIER(ARG) \
  if (ARG.size() != sub_v.st_v.ARG.size()) rcv = 501; \
  rcv = rcv + 1;
`define V5_HIER2(ARG) \
  if (ARG.size() != top_v128f.sub_v.st_v.ARG.size()) rcv = 502; \
  rcv = rcv + 1;
