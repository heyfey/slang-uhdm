// § disableHierNetFirstName415
module top;
  initial begin : blk
    begin : inner
      #10;
    end
  end
  initial begin
    #5 disable blk.inner;
  end
endmodule
