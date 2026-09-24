// § procLvTrailIdxNamesByPath140
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
module dut(input logic [1:0] i, input logic [4:0] flat, output logic [4:0] q);
  p::e_t s;
  always_comb begin
    s = flat;
    s.sat[i]++;
    q = s;
  end
endmodule
