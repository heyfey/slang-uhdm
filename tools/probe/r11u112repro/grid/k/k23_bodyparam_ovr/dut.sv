module sub (input logic [31:0] i, output logic [31:0] o);
  parameter type T = struct packed { logic [31:0] a; logic [7:0] c; };
  T s;
  T [1:0] arr;
  assign s = '0;
  assign arr = '0;
  assign o = i;
endmodule
module top(input logic [31:0] i, output logic [31:0] o);
  sub #(.T(logic [39:0])) u(.i(i), .o(o));
endmodule
