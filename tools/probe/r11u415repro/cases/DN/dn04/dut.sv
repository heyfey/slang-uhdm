// § disableHierNetFirstName415
module top;
  initial begin : blk
    #10;
  end
  initial begin
    #5 disable top.blk;
  end
endmodule
