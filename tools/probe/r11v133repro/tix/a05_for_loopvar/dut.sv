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
module dut(input logic [4:0] flat, output logic o);
  p::e_t s;
  assign s = flat;
  always_comb begin
    o = 1'b0;
    for (int k = 0; k < 4; k++) o = o ^ s.sat[k];
  end
endmodule
