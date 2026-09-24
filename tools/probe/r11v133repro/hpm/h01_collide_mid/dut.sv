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
module dut(input logic clk, input logic r, input logic [13:0] flat, input logic [4:0] fin, output logic o, output logic [4:0] fo);
  p::z_t [1:0] tbl;
  p::e_t f;
  logic [6:0] g;
  assign tbl = flat;
  assign f = fin;
  assign g = {fin, 2'b01};
  always_ff @(posedge clk) o <= tbl[r].g.f.valid ^ f.valid;
  assign fo = f ^ g[6:2];
endmodule
