// § foreachFlatLocalRefTs238
package p;
  class c;
    function void m_set;
      string values[$];
      int vi[4];
      int n;
      foreach (values[i]) n++;
      foreach (vi[j]) vi[j] = n;
    endfunction
  endclass
  function automatic void g;
    string vs[$];
    foreach (vs[k]) vs[k] = "a";
  endfunction
endpackage
module top;
  task automatic t;
    int q[$];
    foreach (q[k]) q[k] = 1;
  endtask
endmodule
