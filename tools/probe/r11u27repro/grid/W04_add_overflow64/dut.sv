module top(output logic [63:0] o);
  logic [63:0] mv;
  assign mv = 64'hFFFFFFFFFFFFFFFF + 64'd1;
  assign o = mv;
endmodule
