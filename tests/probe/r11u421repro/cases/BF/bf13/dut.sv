// § bitsDefNoFoldNoTs421
interface ifc #(parameter w_p = 4) ();
  typedef struct packed { logic [w_p-1:0] data; logic b; } pk_s;
  localparam width_lp = $bits(pk_s);
endinterface
module top; ifc u(); endmodule
