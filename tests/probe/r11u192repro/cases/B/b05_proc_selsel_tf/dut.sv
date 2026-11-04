// § procPsBoundOwner192
package p;
  parameter int unsigned S = $clog2(16);
endpackage
module top import p::*; (input logic [31:0] x [2], output logic [31:0] y1, y2, y3, y4);
  always_comb begin
    y1 = '0;
    for (int i = 0; i < 2; i++) y1 |= {x[i][31:S], 1'b0};
  end
  always_comb y2 = x[0][S:0];
  always_comb y3 = {x[1][31:S], 1'b0};
  function automatic logic [31:0] f(input logic [31:0] a [2]);
    logic [31:0] r;
    r = {a[0][S:0], 1'b0};
    return r;
  endfunction
  assign y4 = f(x);
endmodule
