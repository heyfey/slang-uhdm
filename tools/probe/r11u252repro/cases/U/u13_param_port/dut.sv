// § dupImportSameValueKeeps252
package p;
parameter A = (1<<3);
parameter C = A+1;
endpackage
import p::*;
module top #(parameter W = A) (); endmodule
