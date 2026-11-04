// § concatRangeSelIsConcat401
module top;
  logic [3:0] b, c; logic [1:0] a; int i;
  initial begin a = {b, c}[i +: 2]; a = {b, c}[5 -: 2]; end
endmodule
