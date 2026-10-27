// § emptySlotArgEndPrevTok441
module top;
  int r;
  function automatic int f(int a = 1, int b = 2, int c = 3);
    return a + b + c;
  endfunction
  for (genvar g = 0; g < 2; g++) begin : gb
    wire [31:0] w = f(g,
                   , 7);
  end
endmodule
