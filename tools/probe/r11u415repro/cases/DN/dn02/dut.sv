// § disableHierNetFirstName415
module sub;
  task Read; #5; endtask
  task Write; #5; endtask
endmodule
module top;
  initial begin
    disable u1.Read;
    disable u1.Write;
  end
  sub u1();
endmodule
