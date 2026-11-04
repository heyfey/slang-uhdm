// § emptySlotArgEndPrevTok441
module top;
  task automatic t(int x = 1, int y = 2, int z = 3);
    $display(x, y, z);
  endtask
  initial begin
    t(4,
      ,
      6);
  end
endmodule
