// § dupImportSameValueKeeps252
package p;
typedef logic [3:0] t_t;
parameter A = $bits(t_t) * 2;
parameter B = $bits(logic [2:0]);
endpackage
import p::*;
module top; endmodule
