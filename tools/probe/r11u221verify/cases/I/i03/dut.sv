// § impPatMemberReadKeepsParent215v — a member read of the pattern parameter in another module only, and one in a generate condition
package hp;
  typedef struct packed { logic a; logic [2:0] b; } s_t;
  parameter s_t PA = '{ a: 1'b1, b: 3'd5 };
  parameter s_t PB = '{ a: 1'b0, b: 3'd2 };
endpackage
module m1 import hp::*; (output logic [3:0] o);
  assign o = PA;
endmodule
module m2 import hp::*; (output logic o);
  if (PB.a) begin : g assign o = 1'b1; end
  else begin : ng assign o = PA.b[0]; end
endmodule
module dut (output logic [3:0] o1, output logic o2);
  m1 u1 (.o(o1));
  m2 u2 (.o(o2));
endmodule
