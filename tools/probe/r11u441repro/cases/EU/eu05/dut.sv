// § emptySlotArgEndPrevTok441
class C;
  function int f(int x = 1, int y = 2, int z = 3);
    return x + y + z;
  endfunction
  function int g();
    return f(4,
             , 6);
  endfunction
endclass
module top;
  initial begin
    C c = new;
    $display(c.g());
  end
endmodule
