// § dottedLhsVarOpRhsShares263
package tp;
  typedef enum logic [2:0] { PutFull = 3'h0, Get = 3'h4 } op_e;
  typedef struct packed { logic a_valid; op_e a_opcode; logic [3:0] d; } h2d_t;
endpackage
interface bif;
  logic [3:0] addr;
  modport mp(input addr);
endinterface
module sock #(parameter int unsigned N = 4) (bif.mp bus, input logic a, output logic y);
  tp::h2d_t s;
  assign s.d = bus.addr;
  assign s.a_valid = bus.addr[0] & a;
  always_comb y = s.d[0] ^ s.a_valid;
endmodule
module top(input logic a, output logic y, output logic z);
  bif b();
  sock #(.N(2)) u_a (.bus(b), .a(a), .y(y));
  sock #(.N(3)) u_b (.bus(b), .a(a), .y(z));
endmodule
