package u;
  class fct;
    protected int m_arr[4];
    protected int m_dyn[];
    extern function int print();
  endclass
  function int fct::print();
    int n;
    foreach (m_arr[i]) n = n + m_arr[i];
    foreach (m_dyn[j]) n = n + m_dyn[j];
    return n;
  endfunction
endpackage
package s;
  import u::*;
  int z;
endpackage
module top; endmodule
