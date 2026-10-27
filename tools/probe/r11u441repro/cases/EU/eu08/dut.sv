// § emptySlotArgEndPrevTok441
module top;
  function automatic int f(int x = 1, int y = 2, int z = 3);
    return x + y + z;
  endfunction
  logic [7:0] r;
  assign r = f(4,
               , 6);
endmodule
