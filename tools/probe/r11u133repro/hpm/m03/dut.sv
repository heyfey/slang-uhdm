// § hpBaseSelMidMemberBare133
package p;
  typedef struct packed {
    logic       valid;
    logic [3:0] sat;
  } e_t;
  typedef struct packed {
    e_t f;
  } w_t;
endpackage
module dut(input logic [1:0] r, output logic [9:0] q);
  p::w_t [1:0] tbl;
  always_comb begin
    tbl = 0;
    tbl[r].f.valid = 1'b1;
    q = tbl;
  end
endmodule
