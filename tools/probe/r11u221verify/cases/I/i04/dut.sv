// § impPatCopyFirstListingUnparented215 — a same-named module parameter beside the import (a clone in golden), and a localparam copy of it
package hp;
  typedef struct packed { logic a; logic [2:0] b; } s_t;
  parameter s_t PA = '{ a: 1'b1, b: 3'd5 };
  parameter s_t PB = '{ a: 1'b0, b: 3'd6 };
endpackage
module sub import hp::*; #(parameter s_t PA = hp::PA) (output logic [3:0] o, output logic [3:0] o2);
  localparam s_t LB = PB;
  assign o = PA;
  assign o2 = LB;
endmodule
module dut import hp::*; (output logic [3:0] o, output logic [3:0] o2, output logic [3:0] o3);
  sub u (.o(o), .o2(o2));
  assign o3 = PB;
endmodule
