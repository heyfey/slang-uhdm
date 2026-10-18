// § randSeqListRule401v
module top;
  int x, y;
  task T();
    x = 0;
    randsequence(main) main : first; first : { x = 2; }; endsequence
    y = 3;
  endtask
  initial T();
endmodule
