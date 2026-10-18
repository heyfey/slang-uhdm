// § concatRangeSelIsConcat401
module top;
  logic [3:0] b, c, d; logic [5:0] a;
  initial a = {b, {c, d}}[9:4];
  initial a = {{b}, c}[5:0];
endmodule
