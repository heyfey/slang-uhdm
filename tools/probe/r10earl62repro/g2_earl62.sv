// r10earl62 GRID B — the ENUM half of the Earlgrey witness, cut to its exact
// shape: a MODULE-LOCAL `typedef enum` that NO variable of the module is
// declared with (it is only a STRUCT MEMBER type and a name in expressions),
// in a module with more than one specialization.  g1's version had
// `loc_op_e cur;` beside it, which made our emitter build a FRESH per-instance
// enum_typespec and so registered the second body's enum symbols by accident —
// which is why g1 measured EQUAL on the enum and Earlgrey does not.
// LHS is always golden.
module k62 #(parameter int W = 8) (
  input  logic         clk,
  input  logic [W-1:0] din,
  output logic [W-1:0] dout,
  output logic         f_plain,
  output logic         f_pat,
  output logic         f_proc
);
  // NO variable is declared `e62_t`.
  typedef enum logic [1:0] { EA, EB, EC } e62_t;
  typedef struct packed {
    e62_t       op;
    logic       err;
    logic [1:0] sz;
  } s62_t;

  s62_t v;
  struct packed { logic a; logic b; } pk;

  // (v is left undriven on purpose: an  here brings in an
  // UNRELATED pre-existing pattern-constant head that masks this arm's law.)
  // (1) PLAIN cont_assign RHS
  assign f_plain = (v.op == EB);
  // (2) assignment-pattern member value, ternary CONDITION (the Earlgrey shape)
  assign pk = '{ a: ((v.op != EB) ? 1'b1 : 1'b0), b: (v.op == EC) };
  assign f_pat = pk.a & pk.b;
  // (3) procedural read
  always_comb begin
    f_proc = (v.op == EC) | v.err;
  end
  assign dout = { {(W-2){1'b0}}, v.sz };
endmodule

module top62b (input logic clk, output logic [15:0] o);
  logic [7:0] d8; logic [15:0] d16;
  logic a1,a2,a3,b1,b2,b3;
  k62 #(.W(8))  u_a (.clk(clk), .din(8'h0),  .dout(d8),  .f_plain(a1), .f_pat(a2), .f_proc(a3));
  k62 #(.W(16)) u_b (.clk(clk), .din(16'h0), .dout(d16), .f_plain(b1), .f_pat(b2), .f_proc(b3));
  assign o = d16;
endmodule
