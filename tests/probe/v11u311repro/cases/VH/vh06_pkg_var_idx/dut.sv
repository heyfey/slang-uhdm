// § hcPathIdxBindsDefNet311
package p;
  int k;
endpackage
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (output logic y);
  import p::*;
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  sub u (.a(q.f[k]), .y(y));
endmodule
