// § labeledCallStmtLabelDropped415
module top(input logic [7:0] a, output logic [7:0] o);
  task t(input logic [7:0] x); o = x; endtask
  initial begin : outer
    lt: t(a);
    lf: $finish;
  end
endmodule
