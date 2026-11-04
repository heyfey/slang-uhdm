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
module dut(input logic clk, input logic c, input logic [1:0] i, input logic [9:0] flat, output logic o);
  p::e_t [1:0] tbl;
  assign tbl = flat;
  always_ff @(posedge clk) o <= c ? tbl[1].sat[i] : tbl[0].sat[i + 2'd1];
endmodule
