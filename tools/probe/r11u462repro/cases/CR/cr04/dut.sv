// § clsDynRealArrPropElem462
module top;
  class C;
    real r[$];
    realtime t[string];
    function void f(); r.push_back(1.0); endfunction
  endclass
  C c;
endmodule
