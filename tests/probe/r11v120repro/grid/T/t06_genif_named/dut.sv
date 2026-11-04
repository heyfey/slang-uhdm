module child #(parameter type T = logic) (input T [3:0] a, output logic [15:0] o);
   assign o = 16'(a);
endmodule
module top #(parameter bit EN = 1) (input logic [31:0] x, output logic [15:0] o);
   if (EN) begin : g
      child #(.T(logic [2:0])) u(.a(x[11:0]), .o(o));
   end else begin : h
      child u(.a(x[3:0]), .o(o));
   end
endmodule
