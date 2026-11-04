// § psBoundPaOwnerName192
package p;
  parameter int unsigned S = $clog2(16);
endpackage
module top import p::*; (input logic [31:0] x, output logic [31:0] y1, y2, y4, y5, output logic [31:0] y3 [2]);
  assign y1[S:0] = x[4:0];
  always_comb y2[S:0] = x[4:0];
  for (genvar g = 0; g < 2; g++) begin : gb
    assign y3[g][S:0] = x[4:0];
  end
  task automatic t(input logic [31:0] a, output logic [31:0] b);
    b = {a[S:0], 1'b0};
  endtask
  always_comb t(x, y4);
  always_comb begin
    y5 = '0;
    y5 = x[S-1:0] | {x[31:S]};
  end
endmodule
