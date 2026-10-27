// § emptySlotArgEndPrevTok441
module top;
  int r;
  task automatic t(int a = 1, int b = 2, int c = 3);
    r = a + b + c;
  endtask
  initial t(5,
            , 7);
endmodule
