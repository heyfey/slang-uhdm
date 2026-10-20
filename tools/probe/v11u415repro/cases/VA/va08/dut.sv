// § labeledCallStmtLabelDropped415
module sub;
  task t(input int x); $display(x); endtask
endmodule
module top;
  sub u();
  initial begin
    lh: u.t(5);
  end
endmodule
