// § opIdxRecvElemFollowsPath215 — an interface-class handle array and a pure virtual method called through an operation index, the caller below and above the prototype
package p;
  interface class ic;
    pure virtual function int get();
  endclass
  virtual class base;
    ic objs[4];
    function int early(int i); return objs[i-1].get() + lat(i); endfunction
    pure virtual function int lat(int i);
  endclass
  class der extends base;
    virtual function int lat(int i); return objs[i+1].get(); endfunction
  endclass
endpackage
module m;
endmodule
