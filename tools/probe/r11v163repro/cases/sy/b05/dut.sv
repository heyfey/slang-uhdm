// § elabAggFoldYCopyDefNamed163
package pkg;
  typedef struct packed { logic [7:0] k; logic [7:0] m; } init_t;
  localparam init_t InitDefault = 16'hA5C3;
endpackage
interface ifc import pkg::*; #(parameter init_t Init = InitDefault) ();
  logic [7:0] q;
  assign q = Init.k;
endinterface
module top; ifc i(); endmodule
