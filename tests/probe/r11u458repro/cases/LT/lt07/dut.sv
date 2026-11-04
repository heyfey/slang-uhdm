// § cloneDeclOnlyTwinOwnObject458
package p;
  class C;
    extern   task t();
  endclass
  task C::t();
    int un;
    un = 1;
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
