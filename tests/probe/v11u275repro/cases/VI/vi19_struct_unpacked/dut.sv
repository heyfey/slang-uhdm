// § importNetTsDimEnd275 — a package struct variable with an unpacked dimension
package p;
  typedef struct packed { logic [3:0] a; } s_t;
  s_t v [0:1];
endpackage
module dut (output logic [3:0] o);
  import p::*;
  assign o = v[0].a;
endmodule
