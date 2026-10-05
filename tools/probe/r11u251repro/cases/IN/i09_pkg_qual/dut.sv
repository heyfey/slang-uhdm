// § ifaceDynAliasNetType251
package p; typedef logic [7:0] d_t[]; endpackage
interface ifc; p::d_t d; endinterface
module top; ifc u(); endmodule
