// § cloneForIncBindsHomeVar238
package p;
  parameter int W = 64;
  class fac;
    string m_names[$];
    extern function int find(string s);
    function int in_body();
      int n;
      for (int j = 0; j < 3; j++) n += j;
      return n;
    endfunction
  endclass
  function int fac::find(string s);
    for (int index = 0; index < m_names.size(); ++index)
      if (m_names[index] == s) return index;
    for (bit [W-1:0] b = 0; b < 4; b++) find++;
    return -1;
  endfunction
endpackage
package q;
  import p::*;
  function int g();
    fac f = new;
    return f.find("x") + f.in_body();
  endfunction
endpackage
module top;
  int x;
  initial x = q::g();
endmodule
