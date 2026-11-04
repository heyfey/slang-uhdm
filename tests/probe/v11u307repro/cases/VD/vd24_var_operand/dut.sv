// § deepStubOperandLeafRule307v
module a_m (input logic clk, i, output logic o);
  module b_m (input logic clk, i, output logic o);
    module c_m (input logic x, output logic r); assign r = ~x; endmodule
    logic v;
    always_ff @(posedge clk) v <= i;
    c_m u_c (.x(i & v), .r(o));
  endmodule
  b_m u_b (.clk(clk), .i(i), .o(o));
endmodule
module dut (input logic clk, i, output logic o);
  a_m u_a (.clk(clk), .i(i), .o(o));
endmodule
