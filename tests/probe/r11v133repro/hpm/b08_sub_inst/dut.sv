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
module sub(input logic [13:0] flat, input logic r, output logic o);
  p::w_t [1:0] tbl;
  assign tbl = flat;
  assign o = tbl[r].f.valid;
endmodule
module dut(input logic [13:0] flat, input logic r, output logic [1:0] o);
  sub u0(.flat(flat), .r(r), .o(o[0]));
  sub u1(.flat(~flat), .r(r), .o(o[1]));
endmodule
