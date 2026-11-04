// (r11u191 N0215) a class method formal default reading another formal and a class property
class C;
  int base = 3;
  function int twice(int a); return 2*a; endfunction
  function void m(int a, int b = a + 1, int d = base);
  endfunction
  task t(int a, output int o, input int b = a - 1); o = b; endtask
endclass
module top; endmodule
