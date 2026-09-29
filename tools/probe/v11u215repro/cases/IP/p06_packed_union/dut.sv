// § impPatCopyFirstListingUnparented215 — a packed struct holding a packed union member, imported through two items
package hp;
  typedef union packed { logic [3:0] u; logic [3:0] v; } u_t;
  typedef struct packed { logic a; u_t b; } s_t;
  parameter s_t SA = '{ a: 1'b1, b: 4'd2 };
endpackage
package ip;
  import hp::*;
endpackage
module dut import ip::*; import hp::*; (output logic [4:0] o);
  assign o = SA;
endmodule
