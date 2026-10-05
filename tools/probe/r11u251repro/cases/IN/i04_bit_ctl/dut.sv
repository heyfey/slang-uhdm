// § ifaceDynTdElabVar251 (ifaceDynAliasNetType251 abstains: a two-state element)
typedef bit [3:0] b_t[];
interface ifc; b_t b; endinterface
module top; ifc u(); endmodule
