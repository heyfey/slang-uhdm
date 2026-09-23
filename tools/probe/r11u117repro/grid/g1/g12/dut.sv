// CONTROL: unqualified member select after wildcard import in a module localparam
package q2;
  typedef struct packed { logic [3:0] pad; logic [11:0] v; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, v: {4'h1, 8'h23}, cfg: 2'b11 };
endpackage
module top(output logic [11:0] o);
  import q2::*;
  localparam logic [11:0] V = IMPL.v;
  assign o = V;
endmodule
