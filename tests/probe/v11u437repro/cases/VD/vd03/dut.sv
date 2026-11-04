// § dynArrNewElemLvalueBase437
class K;
  int d[2][];
  function void f(); d[1] = new[2]; endfunction
endclass
module top; K k; initial begin k = new; k.f(); end endmodule
