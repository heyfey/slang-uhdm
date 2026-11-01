// § cloneDeclOnlyTwinOwnObject458
package p;
  typedef struct { bit [7:0] a; int b; } s_t;
  class C;
    extern task t();
  endclass
  task C::t();
    s_t loc;
  endtask
endpackage
package ap;
  import p::*;
  int k;
endpackage
module top;
  import p::*;
  import ap::*;
endmodule
