// § clsTpKwDefaultArrElemAtUse247
package p;
  class q #(type T=int);
    protected T aa[string];
    function int size(); return 0; endfunction
    virtual function void push_back(T item);
      ;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  q#(byte) x;
endmodule
