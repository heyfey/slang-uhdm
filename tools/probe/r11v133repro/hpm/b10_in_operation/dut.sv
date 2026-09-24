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
module dut(input logic [1:0] r, input logic [13:0] flat, output logic o);
  p::w_t [1:0] tbl;
  assign tbl = flat;
  assign o = tbl[r].f.valid & tbl[r+1].f.sat[0];
endmodule
