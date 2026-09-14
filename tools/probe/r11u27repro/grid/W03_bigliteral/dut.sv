module top(output logic [127:0] o);
  logic [127:0] mv;
  assign mv = 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
  assign o = mv;
endmodule
