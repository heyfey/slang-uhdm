// § implicitTsEndCrossesLineBreak200
module l04 (input
    signed a, input
    [3:0] v, output
    wire b);
  assign b = a ^ v[0];
  parameter
     Q = 5;
endmodule
