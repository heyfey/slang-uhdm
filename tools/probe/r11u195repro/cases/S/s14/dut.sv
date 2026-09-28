// § funcCfgPatOpRefBare195 — grid S/s14 (r11u195)
package cp;
  function automatic int f(int x); return x; endfunction
endpackage
module top #(parameter int W = cp::f(8)) (input logic a, output logic [W-1:0] o);
  localparam type it_t = struct packed { logic [W-1:0] S; logic [W-1:0] M; };
  localparam it_t INT = '{S: 1, M: 3};
  assign o = a ? INT.S : INT.M;
endmodule
