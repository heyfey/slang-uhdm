// § emptySlotArgEndPrevTok441
interface ifc;
  int r;
  task automatic t(int a = 1, int b = 2, int c = 3);
    r = a + b + c;
  endtask
endinterface
module top;
  ifc u();
  initial u.t(5,
              , 7);
endmodule
