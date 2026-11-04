// § hpTrailSelIdxNamesByPath133
package p2;
  typedef struct { logic [3:0] sat [4]; } u_t;
endpackage
module dut(input logic [3:0] a, input logic [1:0] i, output logic [3:0] o);
  p2::u_t s;
  always_comb begin
    s.sat[0] = a; s.sat[1] = a; s.sat[2] = a; s.sat[3] = a;
  end
  assign o = s.sat[i];
endmodule
