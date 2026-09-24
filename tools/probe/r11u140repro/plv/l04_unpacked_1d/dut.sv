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
  p::e_t d [1:0];
  always_comb begin
    d[0] = '0; d[1] = '0;
    d[r[0]].sat[i] = 1'b1;
  end
  assign q = d[0];
endmodule
