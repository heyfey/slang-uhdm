// § sizeTickSpaceDropped403
module top;
  logic [63:0] a; logic [7:0] b;
  initial begin
    a = 64 'h 0123_4567_89ab_cdef;
    b = 'h 3;
    b = 8 'o 17;
  end
endmodule
