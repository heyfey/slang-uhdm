// § labeledCallStmtLabelDropped415
module top(input logic [7:0] a, output logic [7:0] o);
  task t(input logic [7:0] x); #5 o = x; endtask
  initial begin
    fork
      lt: t(a);
      #1 disable lt;
    join
  end
endmodule
