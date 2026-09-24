package p1;
  typedef int p1idx;
  function automatic string qj(ref string i[$]);
    string s;
    foreach (i[k]) s = {s, i[k]};
    return s;
  endfunction
  function void dyn(input int a[]); endfunction
  function void fixd(input int b[4]); endfunction
  function automatic void assocs(ref int c[string]); endfunction
  function automatic void assoct(ref int e[p1idx]); endfunction
  class p1cls;
    extern function void m(ref string q[$]);
    function void n(output string w[$]); endfunction
  endclass
  function void p1cls::m(ref string q[$]); endfunction
endpackage

module top;
  import p1::*;
  string qq[$];
  string r;
  task tq(input bit tb[$]); endtask
  function automatic void tf2(ref int f[$][$]); endfunction
  initial r = qj(qq);
endmodule
