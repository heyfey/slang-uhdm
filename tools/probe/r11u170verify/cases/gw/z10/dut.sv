// § tpCloneWholeLhsBare160
module leaf #(parameter type T = logic, parameter bit EN = 1) (input T d_i, output T d_o);
  if (EN) begin : W
    assign d_o = d_i;
  end
endmodule
module top (input logic [7:0] a, output logic [7:0] o, output logic [5:0] p);
  typedef struct packed { logic [3:0] x; logic [3:0] y; } pair_t;
  typedef struct packed { logic [1:0] u; logic [3:0] v; } tri_t;
  leaf #(.T(pair_t)) u1 (.d_i(a), .d_o(o));
  leaf #(.T(tri_t)) u2 (.d_i(a[5:0]), .d_o(p));
endmodule
