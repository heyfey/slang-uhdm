// § disableHierNetFirstName415
module leaf;
  task Read; #5; endtask
endmodule
module mid;
  leaf l();
endmodule
module top;
  mid m();
  initial disable top.m.l.Read;
endmodule
