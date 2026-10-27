// § emptySlotArgEndPrevTok441
package p;
  function automatic int f(int a = 1, int b = 2, int c = 3);
    return a + b + c;
  endfunction
endpackage
module top;
  int r;
  initial r = p::f(5, // c
           , 7);
endmodule
