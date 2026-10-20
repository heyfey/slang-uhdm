// § labeledCallStmtLabelDropped415
module top(input logic [7:0] a, output logic [7:0] o);
  always @(a) begin
    lif: if (a[0]) o = a; else o = 0;
  end
endmodule
