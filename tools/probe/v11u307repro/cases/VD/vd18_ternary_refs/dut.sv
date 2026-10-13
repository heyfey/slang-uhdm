// § deepStubOperandLeafRule307v
module a_m (input logic i, j, k, output logic o);
  module b_m (input logic i, j, k, output logic o);
    module c_m (input logic x, output logic r); assign r = ~x; endmodule
    c_m u_c (.x(j ? i : k), .r(o));
  endmodule
  b_m u_b (.i(i), .j(j), .k(k), .o(o));
endmodule
module dut (input logic i, j, k, output logic o);
  a_m u_a (.i(i), .j(j), .k(k), .o(o));
endmodule
