// § randSequenceDropped401
module top;
  int x, y;
  initial begin : nb
    int k = 5;
    randsequence(main) main : { x = k; }; endsequence
    y = 3;
  end
endmodule
