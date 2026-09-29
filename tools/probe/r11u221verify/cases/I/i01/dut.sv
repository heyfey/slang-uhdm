// § impPatCopyFirstListingUnparented215 — the same packed-struct pattern parameter imported into two modules and a package
package hp;
  typedef struct packed { logic a; logic [2:0] b; } s_t;
  parameter s_t PA = '{ a: 1'b1, b: 3'd5 };
endpackage
package ip;
  import hp::*;
  parameter logic [3:0] PB = PA;
endpackage
module m1 import hp::*; (output logic [3:0] o);
  assign o = PA;
endmodule
module m2 import hp::*; import ip::*; (output logic [3:0] o);
  assign o = PA ^ PB;
endmodule
module dut (output logic [3:0] o1, output logic [3:0] o2);
  m1 u1 (.o(o1));
  m2 u2 (.o(o2));
endmodule
