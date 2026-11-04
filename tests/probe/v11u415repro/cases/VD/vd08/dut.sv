// § disableHierNetFirstName415
module sub;
  task Read; #5; endtask
endmodule
module top;
  sub u1();
  task Read; #5; endtask
  initial begin
    disable Read;
    disable u1.Read;
  end
endmodule
