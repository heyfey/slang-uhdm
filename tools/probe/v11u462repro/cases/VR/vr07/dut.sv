// § clsDynRealArrPropElem462
class C;
  real d[];
  function void f(); d = new[2]; d[0] = 1.5; endfunction
endclass
module top;
  initial begin C c; c = new; c.f(); end
endmodule
