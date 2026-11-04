// § implicitNetMintNoFile131
module top (output logic o);
  task automatic t();
    begin : blk
      o = 1'b1;
      disable blk;
    end
  endtask
  initial t();
endmodule
