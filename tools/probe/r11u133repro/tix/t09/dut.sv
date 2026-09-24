// § hpTrailSelIdxNamesByPath133
package p;
  typedef struct packed {
    logic       valid;
    logic [3:0] sat;
  } e_t;
  typedef struct packed {
    e_t f;
  } w_t;
endpackage
module sub(input logic [1:0] r, input logic [1:0] i, input logic [9:0] flat, output logic o);
  p::e_t [1:0] tbl;
  assign tbl = flat;
  assign o = tbl[r].sat[i];
endmodule
module dut(input logic [1:0] r, input logic [1:0] i, input logic [9:0] flat, output logic o);
  sub u(.r(r), .i(i), .flat(flat), .o(o));
endmodule
