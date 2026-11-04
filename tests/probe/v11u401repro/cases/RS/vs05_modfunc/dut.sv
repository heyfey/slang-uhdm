// § randSequenceDropped401
module top;
  function int F();
    int x;
    randsequence(main) main : { x = 1; }; endsequence
    return x;
  endfunction
  int y;
  initial y = F();
endmodule
