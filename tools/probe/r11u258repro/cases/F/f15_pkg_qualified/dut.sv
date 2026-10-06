// § forMultiInitAssign258 (two initializers, the first a package-qualified variable)
package pv; int gi; endpackage
module m; int j; logic [7:0] y;
  initial begin
    for (pv::gi = 0, j = 0; j < 4; j++) y = j;
  end
endmodule
module top; m u(); endmodule
