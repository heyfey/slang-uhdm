// § impPatCopyFirstListingUnparented215 — controls: an unpacked struct and an array pattern through a re-exporting package stay parented (no firing)
package hp;
  typedef struct { int unsigned a; int unsigned b; } u_t;
  parameter u_t UA = '{ a: 4, b: 8 };
  typedef struct packed { logic a; logic [2:0] c; } e_t;
  parameter e_t AR [2] = '{ '{a: 1'b0, c: 3'd1}, '{a: 1'b1, c: 3'd2} };
endpackage
package ip;
  import hp::*;
  parameter logic [1:0] LOC = 2'b01;
endpackage
module dut import ip::*; (output int o);
  assign o = LOC;
endmodule
