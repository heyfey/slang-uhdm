// § emptySlotArgEndPrevTok441
module sub;
  function automatic int f(int a = 1, int b = 2, int c = 3);
    return a + b + c;
  endfunction
  wire [31:0] w = f(5,
                , 7);
endmodule
module top;
  sub u1();
  sub u2();
endmodule
