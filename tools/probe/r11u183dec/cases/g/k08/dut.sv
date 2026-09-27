package u;
  class fct;
    protected int m_ids[string];
    extern function int print();
  endclass
  function int fct::print();
    int n;
    foreach (m_ids[i]) begin
      n = n + m_ids[i];
    end
    return n;
  endfunction
endpackage
package s;
  import u::*;
  int z;
endpackage
module top; endmodule
