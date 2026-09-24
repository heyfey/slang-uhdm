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
module dut(input p::w_t w, input logic [1:0] i, output logic o);
  assign o = w.f.sat[i];
endmodule
