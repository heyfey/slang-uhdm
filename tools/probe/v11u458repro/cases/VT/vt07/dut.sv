// § cloneDeclOnlyTwinOwnObject458
package p;
  typedef logic [5:0] w_t;
  class C;
    extern task t();
  endclass
  task C::t();
    w_t x;
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
