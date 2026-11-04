module top(output logic [127:0] o);
  logic [127:0] mv;
  assign mv = 128'd2 + 128'd3;
  assign o = mv;
endmodule
