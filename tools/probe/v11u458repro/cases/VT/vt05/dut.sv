// § cloneDeclOnlyTwinOwnObject458
package p;
  class C;
    extern task t();
  endclass
  task C::t();
    int a = 5;
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
