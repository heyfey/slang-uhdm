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
module dut(input logic [1:0] r, input p::w_t in0, output logic o);
  p::w_t tbl [2];
  assign tbl[0] = in0;
  assign tbl[1] = ~in0;
  assign o = tbl[r].f.valid;
endmodule
