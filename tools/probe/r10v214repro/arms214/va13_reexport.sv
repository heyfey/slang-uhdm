// v214 arm 13 — RE-EXPORT.  pv13b wildcard-imports and `export`s pv13a's names;
// pv13c imports pv13b.  Three def clone listings carry class-method bodies that
// read a parameter whose HOME is pv13a.  Only pv13a's own listing may bind
// (§ 178's fence plus this law's home test).
package pv13a;
  parameter int ra13 = 51;
  parameter rb13 = ra13;
  function automatic int rsink13(int a, int b); return a + b; endfunction
  class A13;
    extern function int a_rd13();
  endclass
  function int A13::a_rd13();
    return rsink13(ra13, rb13);
  endfunction
endpackage
package pv13b;
  import pv13a::*;
  export pv13a::*;
  parameter int sb13 = 3;
  class B13;
    extern function int b_rd13();
  endclass
  function int B13::b_rd13();
    return sb13;
  endfunction
endpackage
package pv13c;
  import pv13b::*;
  parameter int tc13 = 4;
  class C13;
    extern function int c_rd13();
  endclass
  function int C13::c_rd13();
    return tc13;
  endfunction
endpackage
module topv13;
  pv13a::A13 a = new();
  pv13b::B13 b = new();
  pv13c::C13 c = new();
  int x, y, z;
  initial begin x = a.a_rd13(); y = b.b_rd13(); z = c.c_rd13(); end
endmodule
