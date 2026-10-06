// § dupImpTypeParamDepAbstains252v
package p;
parameter type T = logic [3:0];
typedef T [1:0] arr_t;
parameter A = $bits(arr_t);
parameter B = 7;
endpackage
import p::*;
module top; endmodule
