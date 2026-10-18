// § randSequenceDropped401
function int F();
  int x;
  randsequence( main )
    main : first second;
    first : { x = x + 1; };
    second : { x = x + 2; };
  endsequence
  return x;
endfunction
module top;
  int x;
  initial x = F();
endmodule
