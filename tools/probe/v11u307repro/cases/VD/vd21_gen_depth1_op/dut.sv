// § deepStubOperandLeafRule307v
module outer (input logic a, b, output logic y);
  module inner (input logic i, output logic o); assign o = ~i; endmodule
  if (1) begin : g
    inner u_in (.i(a ^ b), .o(y));
  end
endmodule
module dut (input logic a, b, output logic y);
  outer u1 (.a(a), .b(b), .y(y));
endmodule
