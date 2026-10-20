// § disableHierNetFirstName415
module sub;
  task Read; #5; endtask
  task Write; #5; endtask
endmodule
module top;
  sub u1();
  sub u2();
  initial begin
    disable u1.Read;
    disable u2.Write;
    disable u1.Write;
  end
endmodule
