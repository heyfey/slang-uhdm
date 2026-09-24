// § pkgParamTsRefColons131
package pk;
  parameter int W = 4;
  class C #(parameter logic [W-1:0] X = '0);
  endclass
endpackage
module top ();
endmodule
