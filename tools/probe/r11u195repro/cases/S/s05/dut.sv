// § funcCfgPatOpRefBare195 — grid S/s05 (r11u195)
package cp;
  function automatic int f(int x); return x; endfunction
endpackage
module top #(parameter int W = cp::f(8)) (input logic a, output logic [7:0] o);
  typedef struct packed { logic [7:0] S; logic [7:0] M; } it_t;
  localparam it_t INT = '{S: W'(1), M: 8'd3};
  assign o = a ? INT.S : INT.M;
endmodule
