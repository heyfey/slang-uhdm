// § defNetClassArrTsDimEnd293
// A never-instantiated interface beside a module.
package pk;
  class C;
    int idx;
  endclass
endpackage
interface ifu;
  import pk::*;
  C a [];
  C b [$];
endinterface
module top;
endmodule
