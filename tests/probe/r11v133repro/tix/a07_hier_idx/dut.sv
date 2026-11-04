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
module dut(input logic [1:0] i, input logic [6:0] flat, output logic o);
  p::w_t s;
  assign s = flat;
  assign o = s.f.sat[s.k];
endmodule
