// § disableHierNetFirstName415
module sub;
  task Read; #5; endtask
endmodule
module a;
  sub u1();
  initial disable u1.Read;
endmodule
module b;
  sub u1();
  initial disable u1.Read;
endmodule
module top;
  a ia();
  b ib();
endmodule
