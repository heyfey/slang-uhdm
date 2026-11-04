// § defNetClassArrTsDimEnd293
// An interface-body fixed array, instantiated.
package pk;
  class C;
    int idx;
  endclass
endpackage
interface ifc;
  import pk::*;
  C a [3];
endinterface
module top;
  ifc u ();
endmodule
