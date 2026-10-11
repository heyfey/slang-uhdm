// § defGenSelRefChainName287
// a member path under a generate block (Earlgrey pinmux shape): golden keeps the stored element names
package p; typedef struct packed { logic [1:0] q; } sel_t; typedef struct packed { sel_t [3:0] insel; } reg_t; endpackage
module m (input p::reg_t reg2hw, input logic [3:0] d [4], output logic [3:0] o [4]);
  for (genvar k = 0; k < 4; k++) begin : gen_mux
    assign o[k] = d[reg2hw.insel[k].q];
  end
endmodule
