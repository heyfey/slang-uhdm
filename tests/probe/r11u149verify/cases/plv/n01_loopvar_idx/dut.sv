// § procLvTrailIdxNamesByPath140
package p;
  typedef struct packed { logic v; logic [3:0] sat; } e_t;
endpackage
module dut(input logic [4:0] d, output logic [4:0] q);
  p::e_t s;
  always_comb begin
    s = d;
    for (int k = 0; k < 4; k++) s.sat[k] = d[k];
    q = s;
  end
endmodule
