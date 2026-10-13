// § deepStubOperandLeafRule307v
module a_m (input logic [1:0] i, output logic [1:0] o);
  module b_m (input logic [1:0] i, output logic [1:0] o);
    module c_m (input logic [2:0] x, output logic [1:0] r); assign r = x[1:0]; endmodule
    c_m u_c (.x({i, i[0] & i[1]}), .r(o));
  endmodule
  b_m u_b (.i(i), .o(o));
endmodule
module dut (input logic [1:0] i, output logic [1:0] o);
  a_m u_a (.i(i), .o(o));
endmodule
