// § hcTrailIdxNamesByPortChain296
package p;
  class C #(int N = 2);
    localparam int M = N + 1;
  endclass
endpackage
module sub4 (input logic [3:0] a, output logic y);
  assign y = a[0];
endmodule
module dut(output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q; int i;
  sub4 u (.a(q.f[i +: p::C#(3)::M]), .y(y));
endmodule
