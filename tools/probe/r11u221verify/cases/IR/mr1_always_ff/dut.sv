// § impPatMemberReadKeepsParent215v — the member read of PA in the importing module: mr1_always_ff (golden's first instance listing unparented unless the read is a constant expression)
package hp;
  typedef struct packed { logic a; logic [2:0] b; } s_t;
  parameter s_t PA = '{ a: 1'b1, b: 3'd5 };
  parameter s_t PB = '{ a: 1'b0, b: 3'd2 };
endpackage
package ip;
  import hp::*;
  export hp::*;
endpackage
module dut import ip::*; import hp::*; (input logic clk, output logic o1, output logic [3:0] o3);
  always_ff @(posedge clk) o1 <= PA.a;
  assign o3 = PB;
endmodule
