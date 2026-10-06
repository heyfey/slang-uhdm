// § dupImpTypeParamDepAbstains252v
package p;
parameter type T = logic [3:0];
parameter A = $bits(T) * 2;
parameter B = $bits(T);
endpackage
import p::*;
module top(output logic [7:0] o);
  assign o = A + B;
endmodule
