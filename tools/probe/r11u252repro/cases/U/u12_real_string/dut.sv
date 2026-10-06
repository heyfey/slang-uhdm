// § dupImportSameValueKeeps252
package p;
parameter real R = 1.5 * 2;
parameter string S = "ab";
parameter A = 3 + 4;
endpackage
import p::*;
module top; endmodule
