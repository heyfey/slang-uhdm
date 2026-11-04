// § delayParenInnerExprSpan292
`define DLY(v) #(v)
`define DLYS(v) #( v )
`define WAITP #( P + 1 )
`define WVAL P + 3
module top;
  parameter int P = 2;
  int x;
  initial begin
    `DLY(P) x = 1;
    `DLY( P + 2 ) x = 2;
    `DLYS(P) x = 3;
    `WAITP x = 4;
    x <= `DLY( P ) 5;
    #(  `WVAL  ) x = 6;
  end
endmodule
