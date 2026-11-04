// § tpCloneWholeLhsBare160
package p; typedef struct packed { logic [3:0] x; logic [3:0] y; } pair_t; endpackage
module leaf #(parameter type T = logic) (input T d_i, output T d_o);
  assign d_o = d_i;
endmodule
module top (input logic [7:0] a, output logic [7:0] o);
  for (genvar i = 0; i < 1; i++) begin : blk
    leaf #(.T(p::pair_t)) u (.d_i(a), .d_o(o));
  end
endmodule
