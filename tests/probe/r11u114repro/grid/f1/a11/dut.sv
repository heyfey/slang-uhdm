// positional (unkeyed) pattern with a concat element
package q2;
  typedef struct packed { logic [3:0] pad; logic [11:0] v; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ 4'h9, {4'h1, 8'h23}, 2'b11 };
endpackage
module top(output logic o);
  assign o = 1'b0;
endmodule
