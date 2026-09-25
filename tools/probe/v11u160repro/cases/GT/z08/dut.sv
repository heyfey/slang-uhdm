// § tpWholeLhsInstantiatedOnly160v
module leaf #(parameter type T = logic, parameter bit W = 0) (input T d_i, output T d_o);
  if (W) begin : g
    assign d_o = d_i;
  end else begin : h
    assign d_o.x = d_i.x;
    assign d_o.y = d_i.y;
  end
endmodule
module top (input logic [7:0] a, output logic [7:0] o);
  typedef struct packed { logic [3:0] x; logic [3:0] y; } pair_t;
  leaf #(.T(pair_t)) u (.d_i(a), .d_o(o));
endmodule
