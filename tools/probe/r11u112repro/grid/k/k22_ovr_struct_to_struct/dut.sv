typedef struct packed { logic [15:0] a; logic [7:0] c; } s_t;
module sub #(parameter type T = struct packed { logic [31:0] a; logic [7:0] c; }) (input logic [31:0] i, output logic [31:0] o);
  T s;
  T [1:0] arr;
  assign s = '0;
  assign arr = '0;
  assign o = i;
endmodule
module top(input logic [31:0] i, output logic [31:0] o);
  sub #(.T(s_t)) u(.i(i), .o(o));
endmodule
