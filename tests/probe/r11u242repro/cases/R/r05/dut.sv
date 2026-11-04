// § impArrParamTsOwnRanges242
// A struct-element array imported, a module-local array parameter (no import: no law), the
// imported array read in constant slots (a part-select width, a replication count).
package hp;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  parameter s_t SA [2] = '{'{a: 1, b: 2}, '{a: 3, b: 4}};
  parameter int W [2] = '{2, 3};
endpackage
module top import hp::*; (input logic [7:0] i, input logic j, output logic [1:0] o, output logic [7:0] r);
  localparam int L [2] = '{5, 6};
  assign o = i[0 +: W[0]];
  assign r = {W[1]{i[j]}} ^ SA[j].a ^ L[j];
endmodule
