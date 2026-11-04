// § psBoundPaOwnerName192
package p;
  parameter int unsigned S = $clog2(16);
endpackage
module top import p::*; (input logic [31:0] x, output logic [31:0] y1, y2, y3, y4, y5, y6, y7, y8, y9);
  assign y1 = x[S:0];
  assign y2 = {x[S:0]};
  assign y3 = x[S:0] + 1;
  assign y4 = {x[31:S], 1'b0};
  assign y5 = x[31:S];
  always_comb y6 = x[S:0];
  always_comb y7 = {x[S:0], 1'b0};
  always_comb begin
    y8 = '0;
    for (int i = 0; i < 2; i++) y8 |= {x[31:S], 1'b0};
  end
  function automatic logic [31:0] f(input logic [31:0] a);
    return a[S:0];
  endfunction
  assign y9 = f(x);
endmodule
