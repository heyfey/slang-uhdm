// § defGenSelRefChainName287
// a reference inside a member path's element select under a generate block
package p; typedef struct packed { logic [1:0] q; } sel_t; typedef struct packed { sel_t [3:0] pad; } reg_t; endpackage
module m (input p::reg_t reg2hw, input logic [3:0] d, output logic o [4]);
  for (genvar k = 0; k < 4; k++) begin : gen_det
    assign o[k] = d[reg2hw.pad[k].q];
  end
endmodule
