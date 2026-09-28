// § foreachAssocLoopVarIdxTs183 § foreachAssocLocalSharesDeclTs183: foreach over a class-keyed and a typedef-keyed associative property and local in a class method, and in a module function
package p;
  class k; endclass
  typedef bit [3:0] t_t;
  class c;
    int pc[k];
    int pt[t_t];
    function int sum();
      int loc[t_t];
      int n;
      foreach (pc[a]) n++;
      foreach (pt[b]) n += pt[b];
      foreach (loc[d]) n--;
      return n;
    endfunction
  endclass
endpackage
module top (output int o);
  typedef logic [2:0] m_t;
  function automatic int g();
    int m[m_t];
    int n;
    foreach (m[i]) n += m[i];
    return n;
  endfunction
  assign o = g();
endmodule
