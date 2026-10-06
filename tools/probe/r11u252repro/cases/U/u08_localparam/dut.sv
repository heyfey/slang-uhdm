// § dupImportSameValueKeeps252
package p;
localparam A = 2**4;
localparam int B = A - 1;
endpackage
import p::*;
module top; endmodule
