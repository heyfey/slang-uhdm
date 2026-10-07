// § paramValRhsSharesParamConst273
package p;
  typedef struct packed { logic [7:0] m; int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{m: 8'hA5, n: 300};
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT) (output logic [31:0] o);
  if (1) begin : g
    logic [7:0] lv;
    assign lv = CFG.m;
    assign o = {24'd0, lv};
  end
endmodule
