// § procLvBaseSelTrailAtIdx140
package p;
  typedef struct packed { logic v; logic [3:0] sat; } e_t;
endpackage
module dut(input logic [1:0] i, input logic [9:0] flat, output logic [9:0] q);
  p::e_t [1:0] tbl;
  always_comb begin
    tbl = flat;
    for (int k = 0; k < 2; k++) tbl[k].sat[i] = 1'b1;
    q = tbl;
  end
endmodule
