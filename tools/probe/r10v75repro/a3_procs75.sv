// r10v75 arm a3 -- PROCEDURE KINDS + subroutine interaction inside a gen scope:
// always @(posedge), always_latch, always_ff, plain always with delay, a
// FUNCTION and a TASK declared in the gen scope and CALLED from the gen-scope
// always (the tfOpFold9 / gsProcOpFold75 fullname precedence question), and a
// module-level function called from a gen-scope always.
package a3p;
  parameter int NB = 4;
endpackage

module a3m #(parameter int P = 1) (input logic clk, input logic rst_n,
                                   output logic [31:0] o);
  import a3p::*;
  logic [31:0] r0, r1, r2, r3, r4, r5, r6;

  function automatic logic [31:0] mfun(input logic [31:0] a);
    mfun = a + {NB{1'b1}};                     // A3_MF module-level function
  endfunction

  if (P > 0) begin : gen_b
    function automatic logic [31:0] gfun(input logic [31:0] a);
      gfun = a | {NB{1'b1}};                   // A3_GF gen-scope function body
    endfunction
    task automatic gtask(output logic [31:0] a);
      a = {NB{1'b1}} ^ 32'h3;                  // A3_GT gen-scope task body
    endtask
    always @(posedge clk) r0 <= {NB{1'b1}};    // A3_P1 always @(posedge)
    always_ff @(posedge clk) r1 <= {NB{1'b1}}; // A3_P2 always_ff
    always_latch if (clk) r2 = {NB{1'b1}};     // A3_P3 always_latch
    always @* r3 = {NB{1'b1}} + 1;             // A3_P4 always @*
    always_comb r4 = gfun(32'h1);              // A3_P5 call gen fn
    always_comb r5 = mfun(32'h1);              // A3_P6 call module fn
    always_comb begin gtask(r6); end           // A3_P7 call gen task
    initial r0 = {NB{1'b1}};                   // A3_P8 initial (fence a)
    final   r1 = {NB{1'b1}};                   // A3_P9 final (fence a)
  end
  assign o = r0 ^ r1 ^ r2 ^ r3 ^ r4 ^ r5 ^ r6;
endmodule

module a3top (input logic clk, input logic rst_n, output logic [31:0] o);
  a3m #(1) u_a (.clk(clk), .rst_n(rst_n), .o(o));
endmodule
