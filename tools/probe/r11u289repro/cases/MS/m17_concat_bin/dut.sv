// § caStructParamModSharesPaOperand289
package q2;
  typedef struct packed { logic [3:0] pad; logic [3:0] a; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, a: {2'b01, 2'b10} };
endpackage
module top import q2::*; (output logic [3:0] o);
  assign o = IMPL.a;
endmodule
