// concat with an enum leaf
package q2;
  typedef enum logic [3:0] { EA = 4'h3, EB = 4'h4 } e_t;
  typedef struct packed { logic [3:0] pad; logic [11:0] v; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, v: {EB, 8'h23}, cfg: 2'b11 };
endpackage
module top(output logic o);
  assign o = 1'b0;
endmodule
