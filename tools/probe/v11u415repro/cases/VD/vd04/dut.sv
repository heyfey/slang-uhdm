// § disableHierNetFirstName415
module sub;
  task Read; #5; endtask
endmodule
module top;
  for (genvar i = 0; i < 2; i++) begin : g
    sub u1();
    initial disable u1.Read;
  end
endmodule
