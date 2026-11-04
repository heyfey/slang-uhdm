// § foreachFlatLocalRefTs238
package p;
  class c;
    extern function void m_set;
  endclass
  function void c::m_set;
    static string values[$];
    static bit first = 1;
    string args[$];
    if (first) begin
      string t[$];
      foreach (values[i]) begin
        args.delete();
        t.push_back(values[i]);
      end
    end
  endfunction
endpackage
module top;
endmodule
