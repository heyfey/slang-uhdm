// qv12 (VERIFIER cell) — q9's FIXED-SIZE array twin.  Same class-homed typedef,
// same class data member + out-of-body method local, but the array is a
// FIXED-size unpacked array, which is emitted by a DIFFERENT stamp site
// (TaskFuncEmit.cpp:~4727) that r10sd4 did NOT gate.
package p12;
  class c12;
    typedef struct { int a; string b; } t12_t;
    t12_t m12[4];
    extern function int f12();
  endclass
  function int c12::f12();
    t12_t l12[4];
    l12[0] = '{a:1, b:"x"};
    return l12[0].a + m12[0].a;
  endfunction
endpackage
module top12;
  p12::c12 h12;
  initial h12 = new();
endmodule
