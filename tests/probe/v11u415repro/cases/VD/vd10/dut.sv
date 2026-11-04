// § disableHierNetFirstName415
module top;
  initial begin : blk
    #10;
  end
  task t;
    disable top.blk;
  endtask
  initial begin
    #5 disable top.blk;
    t();
  end
endmodule
