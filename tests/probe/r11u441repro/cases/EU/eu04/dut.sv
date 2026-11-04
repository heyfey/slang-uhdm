// § emptySlotArgEndPrevTok441
module top;
  function automatic int f(int x = 1, int y = 2, int z = 3);
    return x + y + z;
  endfunction
  int r;
  initial begin
    r = f(4, 5,
         );
  end
endmodule
