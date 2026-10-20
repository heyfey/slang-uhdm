// § labeledCallStmtLabelDropped415
interface ifc;
  int d;
  task Put(input int x); d = x; endtask
endinterface
module top;
  ifc i1();
  initial begin
    lp: i1.Put(3);
  end
endmodule
