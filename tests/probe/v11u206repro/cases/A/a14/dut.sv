// § tpCastUseBindsDefDefault206
typedef struct packed { logic [1:0] a; logic b; } s_t;
module a14 #(parameter type t = s_t) (input logic s, output t o);
  t [3:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    assign x[i] = s ? t'(3'b101) : t'(3'b010);
  end
  assign o = x[0];
endmodule
