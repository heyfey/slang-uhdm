// § defGenUdpFormNoStmt307
module inner (input logic i, output logic o); assign o = ~i; endmodule
module outer (input logic [1:0] a, output logic [1:0] y);
  if (1) begin : g
    inner u_in [1:0] (a, y);
  end
endmodule
module dut (input logic [1:0] a, output logic [1:0] y);
  outer u1 (.a(a), .y(y));
endmodule
