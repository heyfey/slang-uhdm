// § paramValRhsSharesParamConst273
package p;
  typedef struct packed { int unsigned n; logic [7:0] m; } cfg_t;
  localparam cfg_t LIT = '{300, 8'hA5};
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT) (output logic [31:0] o);
  if (1) begin : g
    logic [31:0] lv;
    assign lv = CFG.n;
    assign o = lv;
  end
endmodule
