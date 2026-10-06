// § dupImportSameValueKeeps252
package p;
parameter int A = 1 << 3;
parameter logic [7:0] B = 8'h0f + 1;
endpackage
import p::*;
module top; endmodule
