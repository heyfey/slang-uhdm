// § procLvTrailIdxNamesByPath140
package p;
  typedef struct packed { logic v; logic [3:0] sat; } e_t;
endpackage
module dut(input logic en, input logic [1:0] i, input logic b, output p::e_t s);
  always_latch if (en) s.sat[i] = b;
endmodule
