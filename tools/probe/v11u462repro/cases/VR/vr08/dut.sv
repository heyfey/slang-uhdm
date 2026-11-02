// § clsDynRealArrPropElem462
class C;
  real q[$] = '{1.0, 2.0};
  realtime t[string];
  shortreal s[];
  function void f(); q.push_back(3.0); s = new[1]; endfunction
endclass
module top;
  initial begin C c; c = new; c.f(); end
endmodule
