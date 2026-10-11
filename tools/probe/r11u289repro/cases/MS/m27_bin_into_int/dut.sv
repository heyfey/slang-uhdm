// § caStructParamModSharesPaOperand289
package q2;
  typedef struct packed { logic [3:0] pad; logic [7:0] a; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, a: 8'b1010_0101 };
endpackage
module top import q2::*; (output int o);
  assign o = IMPL.a;
endmodule
