// § hpTrailSelIdxNamesByPath133
package p;
  typedef struct packed {
    logic       valid;
    logic [3:0] sat;
  } e_t;
  typedef struct packed {
    e_t f;
    logic [1:0] k;
  } w_t;
endpackage
module dut #(parameter int P = 1) (input p::e_t s, input logic [1:0] i, output logic o);
  if (P == 1) begin : g1
    assign o = s.sat[i];
  end else begin : g0
    assign o = 1'b0;
  end
endmodule
