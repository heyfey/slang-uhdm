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
module dut(input logic clk, input logic [1:0] i, input logic d, output p::e_t s);
  always_ff @(posedge clk) s.sat[i] <= d;
endmodule
