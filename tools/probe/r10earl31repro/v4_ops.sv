// r10earl31 VERIFIER arm v4 — HOW WIDE IS THE TERNARY OVER-FIRE?  One part-select
// bound per statement, the OPERATOR KIND varying, origin/scope held at the
// witness's.  x2 puts the same parameter in all THREE ternary positions at once,
// so condition vs arms is decided on one line.
//
//   x1 d[pk::DC-1:0]                         arithmetic (the shipped law's cell)
//   x2 d[(pk::DC ? pk::DC : pk::DC)-1:0]     ternary: CONDITION + BOTH ARMS
//   x3 d[(pk::DC<<1)-1:0]                    shift
//   x4 d[{2'b0,pk::DC}-1:0]                  CONCAT inside the bound
//   x5 d[(-pk::DC+8)-1:0]                    unary minus
//   x6 d[(pk::DC>1)+2:0]                     a COMPARISON result
//   x7 d[$signed(pk::DC)+1:0]                sys-func (known-bare control)
package pk;
  localparam logic [3:0] DC = 4'h2;
endpackage

module v4 (
  input  logic [31:0] d,
  output logic [31:0] y
);
  logic [31:0] x1, x2, x3, x4, x5, x6, x7;
  always_comb begin : blk
    x1 = 32'(d[pk::DC-1:0]);
    x2 = 32'(d[(pk::DC ? pk::DC : pk::DC)-1:0]);
    x3 = 32'(d[(pk::DC<<1)-1:0]);
    x4 = 32'(d[{2'b0,pk::DC}-1:0]);
    x5 = 32'(d[(-pk::DC+8)-1:0]);
    x6 = 32'(d[(pk::DC>1)+2:0]);
    x7 = 32'(d[$signed(pk::DC)+1:0]);
  end
  assign y = x1 ^ x2 ^ x3 ^ x4 ^ x5 ^ x6 ^ x7;
endmodule
