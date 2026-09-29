// § impPatCopyFirstListingUnparented215 — controls: an unpacked-struct pattern, an array-of-struct pattern and a packed array-of-packed-struct pattern, imported twice
package hp;
  typedef struct packed { logic a; logic [2:0] b; } s_t;
  typedef struct { logic a; logic [2:0] b; } u_t;
  parameter u_t PU = '{ a: 1'b1, b: 3'd5 };
  parameter s_t PARR [2] = '{ '{ a: 1'b0, b: 3'd1 }, '{ a: 1'b1, b: 3'd2 } };
  parameter s_t [1:0] PPK = '{ '{ a: 1'b0, b: 3'd3 }, '{ a: 1'b1, b: 3'd4 } };
endpackage
package ip;
  import hp::*;
  export hp::*;
endpackage
module dut import hp::*; import ip::*; (output logic [3:0] o1, output logic [3:0] o2, output logic [7:0] o3);
  assign o1 = PU.b;
  assign o2 = PARR[1];
  assign o3 = PPK;
endmodule
