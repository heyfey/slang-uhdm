// § foreachFlatLocalRefTs238
package p;
  class c;
    extern function void m_set;
    extern task m_run;
  endclass
  function void c::m_set;
    static string values[$];
    automatic int dyn[];
    int fix[3];
    int asc[string];
    c objs[$];
    int m2[2][3];
    int n;
    foreach (values[i]) n++;
    foreach (dyn[i]) n += dyn[i];
    foreach (fix[i]) n += fix[i];
    foreach (asc[k]) n++;
    foreach (objs[i]) n++;
    foreach (m2[i, j]) n += m2[i][j];
  endfunction
  task c::m_run;
    string q[$];
    begin
      foreach (q[i]) q[i] = "a";
    end
  endtask
endpackage
module top;
endmodule
