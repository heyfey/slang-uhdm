// § hpTrailSelIdxNamesByPath133
package p;
  typedef struct packed {
    logic       valid;
    logic [3:0] sat;
  } e_t;
  typedef struct packed {
    e_t f;
  } w_t;
endpackage
module dut(input logic r, input logic j, input logic [1:0] i, input logic [19:0] flat, output logic o);
  p::e_t [1:0][1:0] tbl;
  assign tbl = flat;
  assign o = tbl[r][j].sat[i];
endmodule
