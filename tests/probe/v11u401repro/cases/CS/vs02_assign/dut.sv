// § concatRangeSelIsConcat401
module top;
  logic [3:0] b, c; logic [3:0] a;
  assign a = {b, c}[6:3];
endmodule
