// § labeledCallStmtLabelDropped415
module top(input logic [7:0] a, output logic [7:0] o);
  logic [7:0] q[$];
  initial begin
    pb: q.push_back(a);
    o = q[0];
  end
endmodule
