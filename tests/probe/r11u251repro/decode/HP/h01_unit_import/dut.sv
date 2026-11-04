// § unitImportHoistsPkgParams146 (decode only: the module copy of a $unit-imported package parameter lacks its folded value; sister ground, ParamEmit)
package p;
parameter A = (1<<3);
parameter B = 'b0101;
parameter C = A+1;
endpackage
import p::*;
module top; endmodule
