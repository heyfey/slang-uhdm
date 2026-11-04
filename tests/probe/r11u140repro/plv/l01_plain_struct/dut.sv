// § procLvTrailIdxNamesByPath140
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
  p::e_t s;
  always_comb begin
    s = flat[4:0];
    s.sat[i] = 1'b1;
    q = s;
  end
endmodule
