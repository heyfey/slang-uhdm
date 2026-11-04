// § ovrParamBoundOpSelName198
module ch #(parameter int unsigned P = 10, parameter int N = 2) (input logic [31:0] w, output logic [3:0] z, output logic [3:0] z2);
  if (N > 1) begin : g
    always_comb z = w[P+3:P];
    assign z2 = w[P+4:P+1];
  end
endmodule
module top (input logic [31:0] w, output logic [3:0] z, output logic [3:0] z2, output logic [3:0] z3, output logic [3:0] z4);
  ch #(.P(5)) u (.w(w), .z(z), .z2(z2));
  ch #(.P(9)) v (.w(w), .z(z3), .z2(z4));
endmodule
