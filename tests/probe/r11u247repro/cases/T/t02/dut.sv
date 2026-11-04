// § clsTpKwDefaultArrElemAtUse247 (control: a scalar `T v;`, STRICT_EQUAL on both binaries)
package p;
  class q #(type T=int);
    protected T v;
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
