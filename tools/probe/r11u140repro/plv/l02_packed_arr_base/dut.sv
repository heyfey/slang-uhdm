// § procLvBaseSelTrailAtIdx140
package p;
  typedef struct packed {
    logic       valid;
    logic [3:0] sat;
  } e_t;
  typedef struct packed {
    e_t f;
  } w_t;
endpackage
module dut(input logic [1:0] r, input logic [1:0] i, input logic [1:0] k, input logic [9:0] flat, output logic [9:0] q, output logic [9:0] q2);
  p::e_t [1:0] tbl;
  always_comb begin
    tbl = flat;
    tbl[r].sat[i] = 1'b1;
    q = tbl;
  end
endmodule
