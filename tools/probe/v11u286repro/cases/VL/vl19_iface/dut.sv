// § elabCastKeyBindsDefNet286
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p_t;
endpackage
interface ifc;
  import pk::*;
  localparam p_t C = p_t'{a: 4'd1, b: 4'd2};
  logic [7:0] o;
  assign o = C;
endinterface
module top;
  ifc i1();
  ifc i2();
endmodule
