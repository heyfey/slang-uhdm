// § procLvBaseSelTrailAtIdx140
package p;
  typedef struct packed {
    logic       valid;
    logic [3:0] sat;
  } e_t;
  typedef struct packed {
    e_t f;
  } w_t;
  typedef struct packed {
    logic [3:0][1:0] sat;
  } m_t;
endpackage
module dut(input logic r, input logic c, input logic [1:0] i, input logic [19:0] flat, output logic [19:0] q);
  p::e_t [1:0][1:0] tbl;
  always_comb begin
    tbl = flat;
    tbl[r][c].sat[i] = 1'b1;
    q = tbl;
  end
endmodule
