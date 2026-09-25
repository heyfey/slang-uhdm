// § tpWholeLhsInstantiatedOnly160v
typedef struct packed { logic [3:0] x; logic [3:0] y; } pair_t;
module sub #(parameter type T = logic [7:0], parameter int M = 3) (input T d_i, output T d_o);
  case (M)
    1: begin : C assign d_o = d_i; end
    2: begin : C assign d_o = ~d_i; end
    default: begin : C
      if (1) begin : D assign d_o.x = d_i.x; assign d_o.y = 4'h0; end
    end
  endcase
endmodule
module top (input pair_t a, output pair_t c);
  sub #(.T(pair_t)) u(.d_i(a), .d_o(c));
endmodule
