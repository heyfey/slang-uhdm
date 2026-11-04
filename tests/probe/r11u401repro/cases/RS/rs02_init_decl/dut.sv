// § randSequenceDropped401
function int F();
  int sw = 1;
  int x;
  randsequence( main )
    main : if (sw) first else second;
    first : { x = 1; };
    second : { x = 2; };
  endsequence
  return x;
endfunction
module top;
  int x;
  initial x = F();
endmodule
