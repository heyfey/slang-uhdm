// § procLvTrailIdxNamesByPath140
package p;
  typedef struct packed { logic v; logic [3:0] sat; } e_t;
endpackage
module dut(input logic [1:0] m, input logic [1:0] i, input logic [4:0] d, output logic [4:0] q);
  p::e_t s;
  always_comb begin
    s = d;
    case (m)
      2'd0: s.sat[i] = 1'b0;
      default: s.sat[i] = 1'b1;
    endcase
    q = s;
  end
endmodule
