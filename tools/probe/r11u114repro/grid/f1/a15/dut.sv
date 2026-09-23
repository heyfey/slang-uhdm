// concat with an int parameter leaf (32-bit)
package q2;
  localparam int IP = 5;
  typedef struct packed { logic [3:0] pad; logic [35:0] v; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, v: {4'h1, IP}, cfg: 2'b11 };
endpackage
module top(output logic o);
  assign o = 1'b0;
endmodule
