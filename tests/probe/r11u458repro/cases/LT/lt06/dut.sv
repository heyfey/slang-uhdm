// § cloneDeclOnlyTwinOwnObject458
package p;
  typedef union packed { bit [7:0] x; bit [7:0] y; } u_t;
  class C;
    extern   task t();
  endclass
  task C::t();
    u_t un;
  endtask
endpackage
package ap;
  import p::*;
  int k;
endpackage
module top;
  import p::*;
endmodule
