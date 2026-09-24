// r10earl9 witness E — ud.sv MINUS the parameter port list.  ud.sv came out
// cmp-EQUAL (golden keeps `ref_obj (LP)` for a module-local localparam bound),
// so the localparam-vs-parameter cut is NOT the trigger.  rv_timer / usbdev /
// alert_handler — the modules whose bounds golden DOES fold — all have NO
// `#(...)` parameter port list, which is exactly the § modDefImportShape
// distinguisher (pass 4's § impCopyBasedDecKeep found the same flip).
module ue (
  input  logic clk_i,
  output logic o
);
  localparam int LP = 4;
  localparam int LQ = LP + 1;

  import uep::*;                  // a wildcard import in the BODY (rv_timer)

  // row A — var decl bound reading a module-local LOCALPARAM   (rv_timer)
  logic [LP-1:0]            a_v;
  // row C — $clog2 of a module-local localparam                (sha2 shape)
  logic [$clog2(LP)-1:0]    c_v;
  // row E — localparam DECLARED TYPE bound reading a localparam
  localparam logic [LP-1:0] E_P = '0;
  // row G — a computed localparam as a bound
  logic [LQ-1:0]            g_v;
  // row I — a struct member bound reading a localparam
  typedef struct packed { logic [LP-1:0] x; } i_t;
  i_t                       i_v;
  // row J — a var bound reading a WILDCARD-IMPORTED package localparam
  logic [PL-1:0]            j_v;
  // row K — $clog2 of a wildcard-imported package localparam   (sha2)
  logic [$clog2(PL)-1:0]    k_v;
  // row L — $bits of a wildcard-imported package parameter — the u2r
  //         DivisionOfSize shape, which REGRESSED when the substitution was
  //         applied to every query call: $bits asks about the TYPE, so its
  //         argument keeps the symbolic read.
  logic [$bits(PV)-1:0]     l_v;
  // row M — $bits of a QUALIFIED package parameter
  logic [$bits(uep::PV)-1:0] m_v;
  // row N — $size / $high of a package parameter (the other value queries)
  logic [$clog2(uep::PL)-1:0] n_v;

  assign o = clk_i ^ ^a_v ^ ^c_v ^ ^g_v ^ ^i_v ^ ^j_v ^ ^k_v ^ ^l_v ^ ^m_v
             ^ ^n_v ^ ^E_P;
endmodule

package uep;
  localparam int PL = 12;
  parameter logic [2:0] PV = 3'h1;
endpackage
