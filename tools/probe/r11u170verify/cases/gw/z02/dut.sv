// § tpCloneWholeLhsBare160
typedef struct packed { logic [3:0] x; logic [3:0] y; } pair_t;
module sub #(parameter type T = logic [7:0], parameter int M = 1) (input T d_i, output T d_o [2]);
  if (M == 1) begin : A
    for (genvar i = 0; i < 2; i++) begin : F
      assign d_o[i] = d_i;
    end
  end else begin : B
    case (M)
      2: begin : C assign d_o[0].x = d_i.x; end
      default: begin : C assign d_o[1].y = d_i.y; end
    endcase
  end
endmodule
module top (input pair_t a, output pair_t c [2]);
  sub #(.T(pair_t)) u(.d_i(a), .d_o(c));
endmodule
