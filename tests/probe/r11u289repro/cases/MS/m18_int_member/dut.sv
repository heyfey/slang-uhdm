// § caStructParamModSharesPaOperand289
package q2;
  typedef struct packed { int unsigned X; int unsigned Y; } cfg_t;
  localparam cfg_t C = '{X: 32'd64, Y: {16'd1, 16'd2}};
endpackage
module top import q2::*; (output logic [31:0] o);
  assign o = C.Y;
endmodule
