// § dottedLhsVarOpRhsShares263
package tp;
  typedef enum logic [2:0] { PutFull = 3'h0, Get = 3'h4 } op_e;
  typedef struct packed { logic a_valid; op_e a_opcode; logic [3:0] d; } h2d_t;
endpackage
interface ifc #(parameter int N = 1) (input logic a, input logic b);
  tp::h2d_t s;
  tp::h2d_t arr [2];
  assign s.a_valid = a & b;
  assign arr[1].a_valid = a | b;
endinterface
module top(input logic a, input logic b, output logic y);
  ifc #(1) i1 (.a(a), .b(b));
  ifc #(2) i2 (.a(a), .b(b));
  assign y = i1.s.a_valid ^ i2.arr[1].a_valid;
endmodule
