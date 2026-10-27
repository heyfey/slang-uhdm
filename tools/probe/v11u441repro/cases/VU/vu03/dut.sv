// § emptySlotArgEndPrevTok441
class C;
  function int m(int a = 1, int b = 2, int c = 3);
    return a + b + c;
  endfunction
endclass
module top;
  int r;
  initial begin C o = new; r = o.m(5,
                , 7); end
endmodule
