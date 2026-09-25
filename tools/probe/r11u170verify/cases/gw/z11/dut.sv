// § tpWholeLhsInstantiatedOnly160v
module leaf #(parameter type T = logic, parameter int M = 2) (input T d_i, output T d_o);
  case (M)
    1: begin : C assign d_o = d_i; end
    default: begin : C assign d_o.x = d_i.x; assign d_o.y = '0; end
  endcase
endmodule
module top (input logic [7:0] a, output logic [7:0] o);
  typedef struct packed { logic [3:0] x; logic [3:0] y; } pair_t;
  leaf #(.T(pair_t)) u (.d_i(a), .d_o(o));
endmodule
