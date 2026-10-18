// § randSequenceDropped401
module top;
  int x;
  initial begin
    randsequence(top) top : a b; a : { x = 1; }; b : { x = 2; }; endsequence
    x = 9;
  end
endmodule
