module sub #(parameter int W = 8)(output logic [31:0] o);
  logic [31:0] mv;
  assign mv = 32'd2 + 32'd3;
  assign o = mv;
endmodule
module top(output logic [31:0] o2, output logic [31:0] o3);
  sub #(8) u0(.o(o2));
  sub #(16) u1(.o(o3));
endmodule
