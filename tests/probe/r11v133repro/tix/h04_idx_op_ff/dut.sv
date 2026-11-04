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
module dut(input logic clk, input logic [1:0] i, input logic [1:0] j, input logic [9:0] flat, output logic [1:0] o);
  p::w_t [1:0] tbl;
  assign tbl = {flat[6:0], flat[9:3]};
  always_ff @(posedge clk) begin
    o[0] <= tbl[i[0]].f.sat[i + j];
    o[1] <= tbl[j[0]].f.sat[j];
  end
endmodule
