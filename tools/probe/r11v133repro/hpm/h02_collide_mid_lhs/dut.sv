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
module dut(input logic clk, input logic r, input logic d, input logic [4:0] fin, output logic [13:0] q, output logic [4:0] fo);
  p::z_t [1:0] tbl;
  p::e_t f;
  assign f = fin;
  always_ff @(posedge clk) begin
    tbl[r].g.f.valid <= d;
    tbl[r].g.k <= fin[1:0];
  end
  assign q = tbl;
  assign fo = f;
endmodule
