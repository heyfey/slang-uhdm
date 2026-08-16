// qv13 (VERIFIER cell) — q9 with NO array at all: a FLAT local of the
// class-homed type in the out-of-body method, plus a flat class data member.
// Exercises the flat-local stamp site (TaskFuncEmit.cpp:~4969), also un-gated.
package p13;
  class c13;
    typedef struct { int a; string b; } t13_t;
    t13_t m13;
    extern function int f13();
  endclass
  function int c13::f13();
    t13_t l13;
    l13 = '{a:1, b:"x"};
    return l13.a + m13.a;
  endfunction
endpackage
module top13;
  p13::c13 h13;
  initial h13 = new();
endmodule
