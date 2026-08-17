// REPEATED-ACTUAL sub-law: which object takes the stamp when the same actual
// SPELLING appears at more than one argument position of one call inside the
// § pkgRetTopCallArgFormalTs8 window.
package rp10;
  import "DPI-C" context function int dpi10(input int a, input int b, input int c);
  function int f3 (int p0, int p1, int p2); return dpi10(p0, p1, p2); endfunction
  function int f2 (int q0, int q1);         return dpi10(q0, q1, 0); endfunction
  function int t_aaa (int a);          return f3(a, a, a); endfunction
  function int t_aba (int a, int b);    return f3(a, b, a); endfunction
  function int t_aab (int a, int b);    return f3(a, a, b); endfunction
  function int t_abb (int a, int b);    return f3(a, b, b); endfunction
  function int t_dist (int a, int b);   return f2(a, b); endfunction
  function int t_ops (int a);           return f2(a+1, a+1); endfunction
  function int t_consts ();             return f2(1, 1); endfunction
  function int t_sel (logic [7:0] v);   return f2(int'(v[0]), int'(v[0])); endfunction
endpackage
module m10;
  int r[8];
  logic [7:0] vv;
  initial begin
    r[0]=rp10::t_aaa(1); r[1]=rp10::t_aba(1,2); r[2]=rp10::t_aab(1,2);
    r[3]=rp10::t_abb(1,2); r[4]=rp10::t_dist(1,2); r[5]=rp10::t_ops(1);
    r[6]=rp10::t_consts(); r[7]=rp10::t_sel(vv);
  end
endmodule
