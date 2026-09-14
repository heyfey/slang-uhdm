// a20 — THE CONCAT PARAMETER READ WHOLE, THE MODULE HOLDER (R4's other view).
// The leftover encoding is holder-blind (§ modEvalFuncLeftoverEnc's own grid
// says so for a BODY concat); this arm says it for a PARAMETER concat.
package pk;
  typedef struct packed { logic [63:0] r; int unsigned y; } k_t;
endpackage

module dut(output logic o);
  localparam logic [63:0] CAT = {32'd3, 32'd4};
  function automatic pk::k_t mk();
    pk::k_t x; x.r = CAT; x.y = 9; return x;
  endfunction
  localparam pk::k_t K = mk();
  localparam logic [63:0] MR = K.r;
  kid #(.CFG(K)) k0 (.o(o));
endmodule

module kid #(
    parameter pk::k_t CFG = '{r: 0, y: 0}
) (output logic o);
  localparam logic [63:0] S = CFG.r;
  assign o = 1'b0;
endmodule
