// § impCondFlipTakenLeaf242
// The condition and the leaf read another package; the importer at depth 2 under a generate for; the parameter read inside a function body and an always block.
package base;
  parameter int K = 8;
endpackage
package fp;
  parameter int WM = base::K / 4;
  parameter int W = WM == 1 ? 1 : base::K;
  parameter int U = (WM == 2) ? (base::K) : 2;
endpackage
module leaf import fp::*; #(parameter int I = 0) (input logic clk, input logic [15:0] a, output logic [W-1:0] o);
  function automatic logic [W-1:0] g(logic [15:0] x); return x[W-1:0]; endfunction
  always_ff @(posedge clk) o <= g(a) ^ a[U-1:0];
endmodule
module top (input logic clk, input logic [15:0] a, output logic [7:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : gl
    leaf #(.I(i)) u (.clk(clk), .a(a), .o(o[i]));
  end
endmodule
