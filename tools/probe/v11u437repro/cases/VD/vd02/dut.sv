// § dynArrNewElemLvalueBase437
class K;
  function void f(); int d[2][]; d[1] = new[2]; endfunction
endclass
module top; K k; initial begin k = new; k.f(); end endmodule
