// § typedefDimNetDropsDims267
module sha #(parameter type T = logic [7:0]) (input logic [15:0] i, output T [1:0] o);
  assign o = i;
endmodule
module top(input logic [15:0] i, output logic [15:0] o, output logic [7:0] o2);
  sha u_s(.i(i), .o(o));
  sha #(.T(logic [3:0])) u_t(.i(i), .o(o2));
endmodule
