// § dupImportSameValueKeeps252
package p;
parameter A = (1<<3);
parameter C = A+1;
endpackage
import p::*;
interface ifc; logic [A-1:0] d; endinterface
module top; ifc u(); endmodule
