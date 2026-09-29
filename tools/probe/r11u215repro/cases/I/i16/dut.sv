// § impPatMemberReadKeepsParent215v — the module itself reads EA.b (direct import)
package hp;
  typedef struct packed { logic a; logic b; logic [3:0] c; } e_t;
  parameter e_t EA = '{ a: 1'b0, b: 1'b1, c: 4'd3 };
  parameter e_t EB = '{ a: 1'b1, b: 1'b0, c: 4'd9 };
endpackage
module dut import hp::*; (output logic [1:0] o);
  localparam logic X = EA.b;
  assign o = {X, EB.a};
endmodule
