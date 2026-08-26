// r10earl99 g2 -- CONTEXT grid.  Which carriers reach the flatten and which
// must leave the unbased literal alone.
package r99;
  typedef struct packed {
    logic [2:0] a;
    logic [4:0] b;
  } s_t;
  typedef struct packed {
    s_t         inner;
    logic [7:0] c;
  } o_t;
endpackage

module sub99 (input r99::s_t p, output logic [7:0] q);
  assign q = {p.a, p.b};
endmodule

module g2_ctx99 (
  input  logic       sel,
  input  r99::s_t    in_s,
  output r99::s_t    c_pos,      // POSITIONAL pattern in a ternary arm
  output r99::o_t    c_nest,     // NESTED pattern in a ternary arm
  output r99::s_t    c_rep,      // REPLICATED pattern in a ternary arm
  output logic [7:0] c_sub,      // port connection
  output logic [7:0] c_ord,      // ordinary cont-assign, no pattern
  output logic [7:0] c_arith,    // pattern inside an ARM'S ARITHMETIC
  output logic       c_cond,     // unbased literal as a CONDITION
  output logic [7:0] c_cat,      // unbased literal in a CONCAT
  output logic [7:0] c_arg       // unbased literal as a FUNCTION ARGUMENT
);
  function automatic logic [7:0] f99(input logic [7:0] x);
    f99 = x ^ 8'h5a;
  endfunction

  assign c_pos   = sel ? in_s : '{'1, '0};
  assign c_nest  = sel ? '{inner: '{a: '1, b: '0}, c: '1}
                       : '{inner: in_s, c: '0};
  assign c_rep   = sel ? in_s : '{2{'1}};
  assign c_ord   = sel ? 8'hff : '1;
  assign c_arith = sel ? 8'h00 : (8'(r99::s_t'('{a:'1, b:'0})) + 8'd1);
  assign c_cond  = ('1 == sel) ? 1'b1 : 1'b0;
  assign c_cat   = {4'h0, {4{'1}}};
  assign c_arg   = f99('1);

  sub99 u_sub (.p('{a:'1, b:'0}), .q(c_sub));
endmodule
