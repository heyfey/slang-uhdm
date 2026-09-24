// v5 — the container is a MODULE, not a package (§ classInheritsContainerImports23's
// InstanceBody arm).  A different multiplicity and a different container, same
// copy rule -- or not, and then the gate goes on the package arm alone.
package p5;
  int v5 = 3;
endpackage
module m5;
  import p5::*;
  class c5;
    int own5;
  endclass
  c5 h5;
endmodule
