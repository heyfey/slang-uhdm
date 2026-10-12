// § varDeclInitMovesSharedTsEnd297
package p; typedef struct packed { logic [1:0] a; logic b; } t_t; endpackage
module dut(output logic [2:0] o, q);
  p::t_t x = 3'b001;
  p::t_t y = 3'b0_1_0;
  assign o = x;
  assign q = y;
endmodule
