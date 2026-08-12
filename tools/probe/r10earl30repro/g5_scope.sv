// r10earl30 arm g5_scope.sv — AXIS: does the pkg:: QUALIFICATION or the
// IMPORT FORM change the encoding, and does the enclosing SCOPE KIND (module
// body / function body / task body / always_ff / named block / package itself)
// change it?  Origin and base type held at the witness's.
package p5;
  typedef enum logic [2:0] { S0, S1, S2 } s_t;
  // s0  the folded operand INSIDE THE PACKAGE ITSELF
  localparam logic PKGHIT = (S1 == S0);
endpackage

module g5_scope (input logic [2:0] q, input logic clk, output logic [7:0] o);
  import p5::*;                     // wildcard import

  logic [7:0] r;

  // s1  QUALIFIED reference under a wildcard import
  always_comb r[0] = (q == p5::S0);
  // s2  UNQUALIFIED reference resolved through the wildcard import
  always_comb r[1] = (q == S0);
  // s3  UNQUALIFIED, nonzero member
  always_comb r[2] = (q == S1);

  // s4  inside a FUNCTION body
  function automatic logic f5(logic [2:0] x);
    if (x == p5::S0) return 1'b1;
    return 1'b0;
  endfunction
  always_comb r[3] = f5(q);

  // s5  inside a TASK body
  logic tb;
  task automatic t5(logic [2:0] x);
    tb = (x == p5::S1);
  endtask
  always_comb t5(q);
  always_comb r[4] = tb;

  // s6  inside an always_ff (clocked)
  logic ff;
  always_ff @(posedge clk) ff <= (q == p5::S2);
  always_comb r[5] = ff;

  // s7  inside a NAMED begin block
  always_comb begin : nb
    r[6] = (q == p5::S0);
  end

  // s8  inside a generate-if block
  generate
    if (1) begin : gi
      always_comb r[7] = (q == p5::S1);
    end
  endgenerate

  assign o = r;
endmodule
