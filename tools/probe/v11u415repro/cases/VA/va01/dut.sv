// § labeledCallStmtLabelDropped415
module top(input logic [7:0] a, output logic [7:0] o);
  task t(input logic [7:0] x); o = x; endtask
  initial begin
    fork
      c1: t(a);
      c2: $display("%0d", a);
    join
  end
endmodule
