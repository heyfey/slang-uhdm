// § emptySlotArgEndPrevTok441
module top;
  int r;
  function automatic int f(int a = 1, int b = 2, int c = 3);
    return a + b + c;
  endfunction
  initial r = f(
                , 6, 7);
endmodule
