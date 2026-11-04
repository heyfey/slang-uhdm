module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input rt_t rt_i, input logic [1:0] sel, output id_t o);
   assign o = rt_i[sel];
endmodule
module mid #(parameter type X = logic [2:0]) (input logic [31:0] x, output X o);
   child #(.id_t(X)) c(.rt_i(x[4*$bits(X)-1:0]), .sel(x[31:30]), .o(o));
endmodule
module top(input logic [31:0] x, output logic [2:0] o1, output logic [1:0] o2);
   mid m1(.x(x), .o(o1));
   mid #(.X(logic [1:0])) m2(.x(x), .o(o2));
endmodule
