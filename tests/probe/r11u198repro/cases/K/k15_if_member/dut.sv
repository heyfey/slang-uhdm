// § genCaCastRhsRefUnnamed198
typedef struct packed {logic [2:0] f; logic [2:0] h;} st_t;
module top #(parameter int N = 2) (input logic s, output st_t o);
  if (N > 1) begin : g
    assign o.f = 3'(s);
  end
  assign o.h = 3'd0;
endmodule
