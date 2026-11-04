// § paramValRhsSharesParamConst273
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 300};
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT) (output logic [31:0] o);
  if (1) begin : g
    logic [31:0] lv;
    assign lv = CFG.n;
    assign o = lv;
  end
endmodule
