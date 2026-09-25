// § procLvBaseSelTrailAtIdx140
package p;
  typedef struct packed { logic v; logic [3:0] sat; } e_t;
  typedef struct packed { e_t f; } w_t;
endpackage
module dut(input logic r, input logic [1:0] i, input logic [9:0] flat, output logic [9:0] q);
  p::w_t [1:0] tbl;
  always_comb begin
    tbl = flat;
    tbl[r].f.sat[i] = 1'b0;
    q = tbl;
  end
endmodule
