// imported (wildcard) and read unqualified as a whole in a module
package q2;
  typedef struct packed { logic [3:0] pad; logic [11:0] v; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, v: {4'h1, 8'h23}, cfg: 2'b11 };
endpackage
module top import q2::*; (output logic [17:0] o);
  assign o = IMPL;
endmodule
