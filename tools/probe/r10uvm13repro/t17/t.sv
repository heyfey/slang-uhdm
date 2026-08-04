// UVM_*_IMP macro-body shape: a call on a handle whose type is an
// UNSPECIALIZED type parameter defaulting to `int`.
package p1;
  class impc #(type T = int, type IMP = int);
    local IMP m_imp;
    int r;
    function new(IMP imp);
      m_imp = imp;
    endfunction
    task put(T arg);
      m_imp.put(arg);              // A: task-call on an int handle
    endtask
    function bit try_put(T arg);
      return m_imp.try_put(arg);   // B: func-call in a return
    endfunction
    function bit can_put();
      return m_imp.can_put();      // C: no-arg func call
    endfunction
    task get(output T arg);
      m_imp.get(arg);              // D: output formal
    endtask
    function void mix();
      r = m_imp.f(1, 2);           // E: two args
      m_imp.g();                   // F: bare no-arg statement call
    endfunction
  endclass
endpackage

module top;
  import p1::*;
  initial;
endmodule
