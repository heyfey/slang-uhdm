// § deepStubOperandLeafRule307v
module a_m (input logic [1:0] i, j, output logic [1:0] o);
  module b_m (input logic i, j, output logic o);
    module c_m (input logic x, output logic r); assign r = ~x; endmodule
    c_m u_c (.x(i ^ j), .r(o));
  endmodule
  b_m u_b0 (.i(i[0]), .j(j[0]), .o(o[0]));
  b_m u_b1 (.i(i[1]), .j(j[1]), .o(o[1]));
endmodule
module dut (input logic [1:0] i, j, output logic [1:0] o);
  a_m u_a (.i(i), .j(j), .o(o));
endmodule
