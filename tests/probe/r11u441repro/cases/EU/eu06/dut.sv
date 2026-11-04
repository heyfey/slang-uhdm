// § emptySlotArgEndPrevTok441
package p;
  function automatic int f(int x = 1, int y = 2, int z = 3);
    return x + y + z;
  endfunction
endpackage
module top;
  int r;
  initial r = p::f(4,
                   , 6);
endmodule
