module sub(output logic [31:0] o);
  logic [31:0] mv;
  assign mv = 32'd2 + 32'd3;
  assign o = mv;
endmodule
module top(output logic [31:0] o2);
  sub u0(.o(o2));
endmodule
