// § impPatMemberReadKeepsParent215v — member reads inside a module function, a package-qualified member read hp::PA.a, and an always block read of PB.b, beside an unread parameter PC
package hp;
  typedef struct packed { logic a; logic [2:0] b; } s_t;
  parameter s_t PA = '{ a: 1'b1, b: 3'd5 };
  parameter s_t PB = '{ a: 1'b0, b: 3'd2 };
  parameter s_t PC = '{ a: 1'b1, b: 3'd7 };
endpackage
package ip;
  import hp::*;
  export hp::*;
endpackage
module dut import ip::*; import hp::*; (input logic clk, output logic o1, output logic [2:0] o2, output logic [3:0] o3);
  function automatic logic f(); return PA.a; endfunction
  assign o1 = f() ^ hp::PA.a;
  always_ff @(posedge clk) o2 <= PB.b;
  assign o3 = PC;
endmodule
