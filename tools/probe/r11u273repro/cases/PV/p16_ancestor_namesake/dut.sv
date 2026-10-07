// § paramValRhsSharesParamConst273
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 300};
endpackage
module leaf #(parameter p::cfg_t CFG = p::LIT) (output logic [31:0] o_g);
  if (1) begin : gk
    logic [31:0] up_nw;
    assign up_nw = CFG.n;
    assign o_g = up_nw;
  end
endmodule
module dut (output logic [31:0] o_g);
  logic [7:0] up_nw;
  leaf u_l (.o_g(o_g));
  assign up_nw = 8'd0;
endmodule
