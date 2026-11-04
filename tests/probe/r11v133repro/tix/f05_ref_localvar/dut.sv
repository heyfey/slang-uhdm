// § hpTrailSelIdxNamesByPath133
package p;
  typedef struct packed {
    logic       valid;
    logic [3:0] sat;
  } e_t;
  typedef struct packed {
    e_t f;
    logic [1:0] k;
  } w_t;
endpackage
module dut(input p::e_t s, input logic [1:0] i, output logic o);
  always_comb begin
    automatic logic [1:0] j = i + 2'd1;
    o = s.sat[j];
  end
endmodule
