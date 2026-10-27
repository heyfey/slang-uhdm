// § sysCallEmptyArgEndPrevTok441
class C;
  int a = 1, b = 2;
  function void show();
    $display("x", a,
             , b);
  endfunction
endclass
module top;
  initial begin C c = new; c.show(); end
endmodule
