// § doWhileSpansToCloseParen175 § doWhileEndsAtCondEnd178v
`define LIM 5
`define COND(v) v < `LIM
module top;
  int i, j;
  initial begin
    do i++; while (`COND(i));
    do j++; while (j < `LIM);
  end
endmodule
