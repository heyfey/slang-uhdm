// v214 arm 6 — REFERENT SHAPES the fold family owns: a parameter whose Rhs is a
// CONCATENATION, a REPLICATION, an unpacked-array assignment pattern, and a
// parameter with no explicit type, all read from a def clone body.  § 32 / § 178
// say golden may hold no reference at all for some of these; the law must not
// change whichever way they already read.
package pv6;
  parameter logic [7:0] fa6 = 8'h0f;
  parameter logic [15:0] fb6 = {fa6, fa6};
  parameter logic [31:0] fc6 = {4{fa6}};
  parameter int fd6[0:1] = '{3, 4};
  parameter fe6 = fa6;
  function automatic int sink6(int a); return a; endfunction
  class C6;
    extern function int rd6();
  endclass
  function int C6::rd6();
    int r;
    r = sink6(int'(fb6));
    r = r + int'(fc6) + fd6[0] + int'(fe6);
    return r;
  endfunction
endpackage
module topv6;
  pv6::C6 c = new();
  int x;
  initial x = c.rd6();
endmodule
