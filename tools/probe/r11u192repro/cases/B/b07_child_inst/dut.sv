// § psBoundPaOwnerName192
package p;
  parameter int unsigned S = $clog2(16);
endpackage
module sub import p::*; (input logic [31:0] x [2], output logic [31:0] y1, y2, y4, y5, output logic [31:0] y3 [2]);
  assign y1 = x[0][S:0];
  assign y2 = {1'b0, x[1][S:0]};
  for (genvar g = 0; g < 2; g++) begin : gb
    assign y3[g] = {{S{1'b0}}, x[g][S:0]};
  end
  always_comb y4 = {x[1][31:S], 1'b0};
  function automatic logic [31:0] f(input logic [31:0] a);
    return a[S:0];
  endfunction
  assign y5 = f(x[0]);
endmodule
module top (input logic [31:0] x [2], output logic [31:0] y1, y2, y4, y5, output logic [31:0] y3 [2]);
  sub u (.*);
endmodule
