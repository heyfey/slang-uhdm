// § clsTpKwDefaultArrElemAtUse247
package p;
  class q #(type T=int);
    protected T queue[$];
    function int size(); return queue.size(); endfunction
    virtual function void push_back(T item);
      queue.push_back(item);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  q#(byte) x;
endmodule
