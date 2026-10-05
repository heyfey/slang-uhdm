// § unitDynArrTd249 (dynAliasNetType249 abstains: two-state/atom, inline struct or interface def road)
typedef logic [7:0] d_t[];
interface ifc; d_t d; endinterface
module top; ifc i(); endmodule
