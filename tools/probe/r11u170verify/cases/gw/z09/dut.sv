// § tpCloneWholeLhsBare160
module leaf #(parameter type T = logic, parameter int N = 2) (input logic en, output T d_o [N]);
  for (genvar i = 0; i < N; i++) begin : F
    assign d_o[i] = en ? '1 : '0;
  end
endmodule
module top (input logic en, output logic [5:0] o [2]);
  typedef struct packed { logic [2:0] x; logic [2:0] y; } pair_t;
  leaf #(.T(pair_t)) u (.en(en), .d_o(o));
endmodule
