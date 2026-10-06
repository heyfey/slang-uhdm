// § dupImportSameValueKeeps252
package p;
parameter type T = logic [3:0];
parameter A = $bits(T) * 2;
endpackage
import p::*;
module top; T v; endmodule
