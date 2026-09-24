module child #(parameter type T = logic, parameter type U = logic [1:0]) (input T [3:0] a, input U b, output logic [7:0] o);
   assign o = 8'(a) ^ 8'(b);
endmodule
module top(input logic [31:0] x, output logic [7:0] o [2]);
   for (genvar i = 0; i < 2; i++) begin : g
      child #(.T(logic [1:0])) u(.a(x[7:0]), .b(x[9:8]), .o(o[i]));
   end
endmodule
