// § twinElemOnlyNoRange209 — r11u217 t02: PACKAGE functions (not class methods) returning dynamic / queue / associative typedefs of int and of an unpacked struct, and a queue of queues, called from a module initial block
package p;
  typedef struct { int a; byte b; } s_t;
  typedef int di_t[];
  typedef s_t qs_t[$];
  typedef int aa_t[byte];
  typedef di_t qq_t[$];
  function automatic di_t g1(); di_t r; r = new[2]; return r; endfunction
  function automatic qs_t g2(); qs_t r; return r; endfunction
  function automatic aa_t g3(); aa_t r; return r; endfunction
  function automatic qq_t g4(); qq_t r; return r; endfunction
endpackage
module top;
  import p::*;
  int n;
  initial begin
    di_t x;
    x = g1();
    n = x.size();
  end
endmodule
