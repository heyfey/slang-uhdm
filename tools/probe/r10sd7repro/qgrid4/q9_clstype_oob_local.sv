// q9 — BuildUVMPkg's head shape, minimised.  ONE typedef declared INSIDE the
// class, used BOTH as a class data-member queue AND as an out-of-body method's
// queue local.  We emit ONE struct_typespec for the typedef and SHARE it, so
// the method-local stamp (`makeQueueDynArrayVar`, home package) lands on the
// object the class data member also points at.
package p9;
  class c9;
    typedef struct { int a; string b; } t9_t;
    t9_t m9[$];
    extern function int f9();
  endclass
  function int c9::f9();
    t9_t l9[$];
    l9.push_back('{a:1, b:"x"});
    return l9.size() + m9.size();
  endfunction
endpackage
module top9;
  p9::c9 h9;
  initial h9 = new();
endmodule
