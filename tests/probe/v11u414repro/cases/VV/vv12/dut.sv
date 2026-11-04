// § varInitUintMask414
module top;
  integer i = 4294967297;
  logic [63:0] q = 18446744073709551615;
  initial $display(i, q);
endmodule
