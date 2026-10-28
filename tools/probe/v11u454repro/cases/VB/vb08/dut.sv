// § unpackedDimBasedLitKept454
module sub #(parameter W = 4);
  logic [W-1:0] mem [8'h0:8'h3];
  assign mem[0] = '0;
endmodule
module top;
  sub #(2) a();
  sub #(8) b();
endmodule
