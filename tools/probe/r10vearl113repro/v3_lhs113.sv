// r10vearl113 (VERIFIER) arm v3 -- THE LHS-KIND AND CARRIER AXES with
// GEN-LOCAL targets.  MEASUREMENT ONLY.
//
// The fence's NamedValue test decides `genCaLhsGenLocal113`; anything that is
// not a plain named reference falls THROUGH the suppress and keeps the stamp.
// Each cell here is a gen-local target reached by a different Lhs form, plus
// the carriers that are NOT a cont_assign at all.
//   c1  gen-local ARRAY ELEMENT target (bit_select Lhs)
//   c2  gen-local STRUCT MEMBER target (member-select Lhs)
//   c3  gen-local NET-DECL-ASSIGN (a different emitter path entirely)
//   c4  gen-local target driven by an always_comb
//   c5  gen-local target driven by an initial
//   c6  gen-local target driven by a DELAYED continuous assign
//   c7  gen-local PART-SELECT target
//   c8  a gen-local target assigned through an explicit CAST
package pv3113;
  typedef enum logic [2:0] { XA = 3'h0, XB = 3'h4 } xe_e;
  typedef struct packed {
    logic       v;
    xe_e        o;
    logic [7:0] d;
  } xs_t;
  typedef struct packed {
    xs_t        inr;
    logic [7:0] tail;
  } xw_t;
endpackage

module v3_lhs113 #(parameter int M = 2) (
  input  logic        clk,
  input  pv3113::xs_t tl_i [M],
  input  logic [7:0]  d_i,
  output logic        y_o
);
  for (genvar i = 0; i < M; i++) begin : gen_c
    // c1  ARRAY ELEMENT
    pv3113::xs_t c1_arr [2];
    assign c1_arr[0] = '{ v: tl_i[i].v, o: tl_i[i].o, d: d_i };

    // c2  STRUCT MEMBER
    pv3113::xw_t c2_w;
    assign c2_w.inr = '{ v: tl_i[i].v, o: tl_i[i].o, d: d_i };

    // c3  NET-DECL-ASSIGN
    pv3113::xs_t c3_nda = '{ v: tl_i[i].v, o: tl_i[i].o, d: d_i };

    // c4  ALWAYS_COMB
    pv3113::xs_t c4_ac;
    always_comb c4_ac = '{ v: tl_i[i].v, o: tl_i[i].o, d: d_i };

    // c5  INITIAL
    pv3113::xs_t c5_in;
    initial c5_in = '{ v: tl_i[i].v, o: tl_i[i].o, d: d_i };

    // c6  DELAYED CONTINUOUS ASSIGN
    pv3113::xs_t c6_dl;
    assign #1 c6_dl = '{ v: tl_i[i].v, o: tl_i[i].o, d: d_i };

    // c8  EXPLICIT CAST on the pattern
    pv3113::xs_t c8_cast;
    assign c8_cast = pv3113::xs_t'('{ v: tl_i[i].v, o: tl_i[i].o, d: d_i });
  end

  // the module-scope twins of c1/c2 (golden's own behaviour at module scope)
  pv3113::xs_t mc1_arr [2];
  assign mc1_arr[0] = '{ v: tl_i[0].v, o: tl_i[0].o, d: d_i };
  pv3113::xw_t mc2_w;
  assign mc2_w.inr = '{ v: tl_i[0].v, o: tl_i[0].o, d: d_i };

  assign y_o = mc1_arr[0].v ^ mc2_w.inr.v;
endmodule
