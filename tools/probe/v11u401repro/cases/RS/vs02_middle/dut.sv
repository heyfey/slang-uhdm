// § randSequenceDropped401
module top;
  int x, y, z;
  initial begin
    z = 0;
    randsequence(main) main : { x = 1; }; endsequence
    y = 2;
  end
  always @(x) z = 1;
endmodule
