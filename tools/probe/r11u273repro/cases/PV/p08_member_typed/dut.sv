// § paramValRhsSharesParamConst273
package p;
  typedef struct packed { int unsigned n; logic [7:0] m; } cfg_t;
  localparam cfg_t LIT = '{n: 300, m: 8'hA5};
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT) (output logic [31:0] o, output logic [7:0] q);
  assign o = CFG.n;
  assign q = CFG.m;
endmodule
