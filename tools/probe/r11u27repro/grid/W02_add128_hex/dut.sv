module top(output logic [127:0] o);
  logic [127:0] mv;
  assign mv = 128'h2 + 128'h3;
  assign o = mv;
endmodule
