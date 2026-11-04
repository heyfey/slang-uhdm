// § procLvTrailIdxNamesByPath140
package p;
  typedef struct packed { logic v; logic [3:0] sat; } e_t;
  typedef struct packed { logic [1:0] idx; } c_t;
endpackage
module dut(input p::c_t c, input logic [4:0] d, output logic [4:0] q);
  p::e_t s;
  always_comb begin
    s = d;
    s.sat[c.idx] = 1'b1;
    q = s;
  end
endmodule
