// § hpBaseSelMidMemberBare133
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
module dut(input logic clk, input logic [1:0] r, input logic [3:0] d, output logic [13:0] q);
  p::w_t [1:0] tbl;
  always_ff @(posedge clk) tbl[r].f.sat <= d;
  assign q = tbl;
endmodule
