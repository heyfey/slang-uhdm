// § unpackedDimBasedLitKept454
module sub(input logic p [1'b1:0], output logic o [2'd1:2'd0]);
  assign o[0] = p[0];
  assign o[1] = p[1];
endmodule
module top;
  logic a [2], b [2];
  sub s(.p(a), .o(b));
endmodule
