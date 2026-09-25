// § defGenLhsHpBaseAnchor144 + § procLvTrailIdxNamesByPath140 (composition)
package p;
  typedef struct packed { logic v; logic [3:0] sat; } e_t;
endpackage
module dut(input logic [1:0] a, input logic [1:0] i, input logic [4:0] d, output logic [4:0] q, output logic [9:0] o);
  p::e_t [1:0] s;
  for (genvar g = 0; g < 2; g++) begin : gb
    assign s[g].v = a[g];
    assign s[g].sat = 4'h0;
  end
  p::e_t t;
  always_comb begin
    t = d;
    t.sat[i] = 1'b1;
    q = t;
  end
  assign o = s;
endmodule
