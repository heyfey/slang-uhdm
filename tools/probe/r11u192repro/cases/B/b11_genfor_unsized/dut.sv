// § genForReplCountOwner192
package p;
  parameter int unsigned S = $clog2(16);
endpackage
module top import p::*; (input logic [1:0] c, input logic [7:0] a [2], input logic [3:0] b, input logic [7:0] x,
  output logic [7:0] y1 [2], output logic [7:0] y2 [2], output logic [7:0] y3 [2], output logic [7:0] y4 [2],
  output logic [7:0] y5 [2], output logic [7:0] y6 [2], output logic [7:0] y7 [2], output logic [7:0] z1, output logic [7:0] z2, output logic [7:0] z3);
  for (genvar g = 0; g < 2; g++) begin : gb
    assign y1[g] = c[g] ? '0 : (a[g] + {{S{1'b0}}, b});
    assign y2[g] = c[g] ? {{S{1'b0}}, b} : (a[g] + {{S{1'b0}}, b});
    assign y3[g] = c[g] ? 8'd0 : (a[g] + {{S{1'b0}}, b});
    assign y4[g] = a[g] + {{S{1'b0}}, b};
    assign y5[g] = c[g] ? '1 : {{S{1'b0}}, b};
    assign y6[g] = c[g] ? '0 : x[S:0];
    assign y7[g] = c[g] ? '0 : {1'b0, x[S:0]};
  end
  assign z1 = c[0] ? '0 : x[S:0];
  assign z2 = c[0] ? '0 : {1'b0, x[S:0]};
  assign z3 = (c[0] & '1) | {{S{1'b0}}, b};
endmodule
