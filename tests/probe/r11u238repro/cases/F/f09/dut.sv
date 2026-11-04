// § foreachFlatLocalRefTs238
package p;
  class c;
    extern function void m_set(string s);
  endclass
  function void c::m_set(string s);
    static string values[$];
    static bit first = 1;
    string args[$];
    if (first) begin
      string t[$];
      values.push_back(s);
      foreach (values[i]) begin
        args.delete();
        t.push_back(values[i]);
      end
    end
  endfunction
endpackage
module top;
endmodule
