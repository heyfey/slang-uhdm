// MODULE home: the same pattern as a module localparam
package q2;
  typedef struct packed { logic [3:0] pad; logic [11:0] v; logic [1:0] cfg; } impl_t;
endpackage
module top(output logic [17:0] o);
  localparam q2::impl_t IMPL = '{ pad: 4'h9, v: {4'h1, 8'h23}, cfg: 2'b11 };
  assign o = IMPL;
endmodule
