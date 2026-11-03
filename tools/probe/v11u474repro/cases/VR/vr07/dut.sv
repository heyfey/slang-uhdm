// § clsScopedRangeKept474 (attack: generate-block net)
package p; class S; localparam w = 8; endclass endpackage
module top; import p::*;
  for (genvar g = 0; g < 2; g++) begin : gb
    wire [S::w-1:0] a;
  end
endmodule
