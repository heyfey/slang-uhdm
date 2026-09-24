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
  typedef struct packed {
    w_t g;
  } z_t;
endpackage
module dut(input logic clk, input logic [1:0] i, input logic [9:0] flat, input logic r, output logic o, output logic [3:0] sat);
  p::e_t [1:0] tbl;
  assign tbl = flat;
  assign sat = flat[3:0] ^ {2'b0, i};
  always_ff @(posedge clk) o <= tbl[r].sat[i] ^ sat[i];
endmodule
