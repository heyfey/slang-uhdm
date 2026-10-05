// § foreachFlatLocalRefTs238
package p;
  class c;
    function void m_set(string s);
      static string values[$];
      if (s != "") begin
        int n;
        foreach (values[i]) n++;
      end
      foreach (values[j]) values[j] = s;
    endfunction
  endclass
endpackage
module top;
endmodule
