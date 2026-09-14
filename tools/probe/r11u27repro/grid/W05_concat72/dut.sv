module top(output logic [71:0] o);
  logic [71:0] mv;
  assign mv = {8'hFF, 64'd3};
  assign o = mv;
endmodule
