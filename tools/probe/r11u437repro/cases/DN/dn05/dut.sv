// § dynArrNewElemLvalueBase437
class C;
  int d[2][];
  function void f(); d[0] = new[3]; endfunction
endclass
module top; C c; initial begin c = new; c.f(); end endmodule
