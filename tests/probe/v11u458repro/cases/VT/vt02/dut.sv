// § cloneDeclOnlyTwinOwnObject458
package p;
  task automatic t();
    int un;
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
