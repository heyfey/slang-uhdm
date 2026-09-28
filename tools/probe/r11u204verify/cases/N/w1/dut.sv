// § ovrParamBoundOpSelName198: overridden parameters in part-select bound operations (a product plus a constant, a shift, an indexed part-select base operation), two instances with different overrides
module ch #(parameter int unsigned P = 2, parameter int N = 2) (input logic [31:0] w, output logic [3:0] y, output logic [1:0] z, output logic [7:0] v);
  if (N > 1) begin : g
    assign y = w[P*2+3:P*2];
    assign z = w[P+1 -: 2];
    assign v = w[31:P<<2];
  end
endmodule
module top (input logic [31:0] w, output logic [3:0] y1, y2, output logic [1:0] z1, z2, output logic [7:0] v1, v2);
  ch #(.P(3)) u1 (.w(w), .y(y1), .z(z1), .v(v1));
  ch #(.P(5)) u2 (.w(w), .y(y2), .z(z2), .v(v2));
endmodule
