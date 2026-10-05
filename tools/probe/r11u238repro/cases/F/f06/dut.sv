// § foreachFlatLocalRefTs238
package p;
  class c;
    extern function void m_set(string s);
  endclass
  function void c::m_set(string s);
    static string values[$];
    string args[$];
    values.push_back(s);
    foreach (values[i]) begin
      args.delete();
      args.push_back(values[i]);
    end
  endfunction
endpackage
module top;
endmodule
