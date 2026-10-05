// § foreachFlatLocalRefTs238
package p;
  class c;
    function void m_set(string s);
      static string values[$];
      static int vals2[4];
      values.push_back(s);
      foreach (values[i]) values[i] = s;
      foreach (vals2[k]) vals2[k] = 1;
    endfunction
  endclass
endpackage
module top;
endmodule
