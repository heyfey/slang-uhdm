// concat with an x digit
package q2;
  typedef struct packed { logic [3:0] pad; logic [7:0] v; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, v: {4'b10x1, 4'h2}, cfg: 2'b11 };
endpackage
module top(output logic o);
  assign o = 1'b0;
endmodule
