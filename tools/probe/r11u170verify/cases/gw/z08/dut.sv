// § tpWholeLhsInstantiatedOnly160v
module leaf #(parameter type T = logic, parameter int N = 0) (input T d_i, output T d_o);
  for (genvar i = 0; i < N; i++) begin : F
    assign d_o = d_i;
  end
  if (N == 0) begin : M
    assign d_o.x = d_i.y;
    assign d_o.y = d_i.x;
  end
endmodule
module top (input logic [7:0] a, output logic [7:0] o);
  typedef struct packed { logic [3:0] x; logic [3:0] y; } pair_t;
  leaf #(.T(pair_t)) u (.d_i(a), .d_o(o));
endmodule
