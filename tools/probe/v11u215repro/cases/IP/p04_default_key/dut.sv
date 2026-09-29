// § impPatCopyFirstListingUnparented215 — default-keyed and positional patterns, imported through ip then hp
package hp;
  typedef struct packed { logic a; logic b; logic [3:0] c; } e_t;
  parameter e_t ED = '{ default: 1'b0 };
  parameter e_t EP = '{ 1'b1, 1'b0, 4'd5 };
  parameter e_t EM = '{ a: 1'b1, default: 1'b0 };
endpackage
package ip;
  import hp::*;
  parameter logic [1:0] LOC = 2'b01;
endpackage
module dut import ip::*; import hp::*; (output logic [5:0] o);
  assign o = ED ^ EP ^ EM;
endmodule
