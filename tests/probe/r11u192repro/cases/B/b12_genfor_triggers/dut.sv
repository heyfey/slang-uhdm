// § genForReplCountOwner192
package p;
  parameter int unsigned S = $clog2(16);
endpackage
module top import p::*; (input logic [1:0] c, input logic [7:0] a [2], input logic [3:0] b,
  output logic [7:0] y1 [2], output logic [7:0] y2 [2], output logic [7:0] y3 [2], output logic [7:0] y4 [2],
  output logic [7:0] y5 [2], output logic [7:0] y6 [2]);
  function automatic logic [7:0] f(input logic [7:0] v);
    return v;
  endfunction
  for (genvar g = 0; g < 2; g++) begin : gb
    assign y1[g] = 8'(a[g]) + {{S{1'b0}}, b};
    assign y2[g] = a[g] + {{S{1'b0}}, b} + 0;
    assign y3[g] = f(a[g]) + {{S{1'b0}}, b};
    assign y4[g] = c[g] ? 'x : (a[g] + {{S{1'b0}}, b});
    assign y5[g] = (a[g] & '1) + {{S{1'b0}}, b};
    assign y6[g] = c[g] ? 'z : {{S{1'b0}}, b};
  end
endmodule
