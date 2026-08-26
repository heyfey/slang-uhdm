// r10earl97 g4 -- FORM GRID.  The distinguishers § castTypedParamDeclTs is
// gated on: a LITERAL default vs a COMPUTED one, a BARE cast width vs a
// PARENTHESISED one, and a signed vs an `unsigned` declaration keyword.
module top4f97;
  logic [31:0] o;
  sub4f97 #(.InW(8)) u_s(.o(o));
endmodule
module sub4f97 #(parameter int InW = 32) (output logic [31:0] o);
  logic [3:0] m;
  localparam int          W_LIT  = 6;                 // literal default
  localparam int          W_CALC = $clog2(InW + 1);   // computed default
  localparam int unsigned W_UNS  = $clog2(InW + 2);   // computed, unsigned
  localparam int          W_PAR  = 7;                 // used parenthesised
  assign o = 32'(W_LIT'(m)) + 32'(W_CALC'(m)) + 32'(W_UNS'(m))
           + 32'((W_PAR)'(m));
endmodule
