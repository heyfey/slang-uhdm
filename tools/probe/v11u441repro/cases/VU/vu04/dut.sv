// § emptySlotArgEndPrevTok441
class C;
  int s;
  function new(int a = 1, int b = 2, int c = 3);
    s = a + b + c;
  endfunction
endclass
module top;
  initial begin C o = new(5,
                , 7); end
endmodule
