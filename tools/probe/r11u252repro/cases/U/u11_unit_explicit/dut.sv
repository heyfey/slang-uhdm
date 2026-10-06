// § dupImportSameValueKeeps252
package p;
parameter A = (1<<3);
parameter C = A+1;
endpackage
import p::A;
import p::*;
module top; endmodule
