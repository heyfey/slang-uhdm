// § deepStubOperandLeafRule307v
module a_m (input logic i, j, k, output logic o);
  module b_m (input logic i, j, k, output logic o);
    module c_m (output logic r, input logic x); assign r = ~x; endmodule
    c_m u_c ({o}, i & j);
  endmodule
  b_m u_b (.i(i), .j(j), .k(k), .o(o));
endmodule
module dut (input logic i, j, k, output logic o);
  a_m u_a (.i(i), .j(j), .k(k), .o(o));
endmodule
