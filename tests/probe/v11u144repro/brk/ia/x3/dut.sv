// § caSelLhsBareDecNoAdjust144
typedef logic [7:0] byte_t;
module top(output byte_t o);
  byte_t b;
  assign b[2] = 5;
  assign b[1:0] = 7;
  assign b[7:3] = 100;
  assign o = b;
endmodule
