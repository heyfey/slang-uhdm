// § disableHierNetFirstName415
module sub;
  initial begin : blk
    #10;
  end
endmodule
module top;
  sub u1();
  initial begin
    #5 disable u1.blk;
  end
endmodule
