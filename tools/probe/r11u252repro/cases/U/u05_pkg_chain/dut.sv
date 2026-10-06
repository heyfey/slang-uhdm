// § dupImportSameValueKeeps252
package p;
parameter A = (1<<3);
endpackage
package p2;
import p::*;
parameter C = A*2;
endpackage
import p2::*;
module top; endmodule
