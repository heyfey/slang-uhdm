// § clsTdUnionClsEnumMemberShares237
// the enum declared in the base class (the uvm_comparer shape of pass 235's r01)
package p;
class b;
  typedef enum {NEVER, STARTED, FINISHED} rs_e;
endclass
class d extends b;
  typedef union packed { rs_e s; int raw; } su_t;
  su_t m;
endclass
endpackage
module top;
endmodule
