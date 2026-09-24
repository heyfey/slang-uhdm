// § procLvBaseSelTrailAtIdx140
package p;
  typedef struct packed {
    logic       valid;
    logic [3:0] sat;
  } e_t;
endpackage
module dut(input logic r, input logic [1:0] i, output logic q);
  p::e_t tbl [2];
  always_comb begin
    tbl[0] = '0; tbl[1] = '0;
    tbl[r].sat[i] = 1'b1;
    q = tbl[1].sat[0];
  end
endmodule
