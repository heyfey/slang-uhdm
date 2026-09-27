package u;
  class w; endclass
  class q; endclass
  class fct;
    protected q m_qs[w];
    extern function void print();
  endclass
  function void fct::print();
    w obj;
    foreach (m_qs[i]) begin
      obj = i;
    end
  endfunction
endpackage
package s;
  import u::*;
  int z;
endpackage
module top; endmodule
