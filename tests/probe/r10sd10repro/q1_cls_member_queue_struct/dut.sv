// q1 — a QUEUE data member of a class, element type a struct TYPEDEF declared
// INSIDE the class.  This is BuildUVMPkg's head shape exactly
// (`m_inst_typename_alias_t m_inst_aliases[$]` in class uvm_default_factory).
package p1;
  class c1;
    typedef struct { int a; string b; } alias_t;
    alias_t q1[$];
  endclass
endpackage
module top1;
  p1::c1 h1;
  initial h1 = new();
endmodule
