// § genProcFoldDeclTsScopeNamed167 — a packed-struct typed parameter folded in a gen-if process (not a logic/bit range: the law abstains)
typedef struct packed { logic [3:0] hi; logic [3:0] lo; } w_t;
module top #(parameter w_t Z = '{hi: 4'd1, lo: 4'd2}) (input logic clk, output w_t q);
  if (1) begin : g
    always_ff @(posedge clk) q <= Z;
  end
endmodule
