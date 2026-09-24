// § procLvBaseSelTrailAtIdx140
package p;
  typedef struct packed {
    logic       valid;
    logic [3:0] sat;
  } e_t;
endpackage
interface ifc;
  p::e_t [1:0] tbl;
endinterface
module dut(input logic [1:0] r, input logic [1:0] i, output logic [9:0] q);
  ifc u();
  always_comb begin
    u.tbl = '0;
    u.tbl[r].sat[i] = 1'b1;
    q = u.tbl;
  end
endmodule
