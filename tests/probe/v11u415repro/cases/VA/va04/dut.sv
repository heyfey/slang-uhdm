// § labeledCallStmtLabelDropped415
class K;
  int n;
  task run(int k); n = k; endtask
  task go();
    lc: this.run(3);
    lf: run(4);
  endtask
endclass
module top;
  K h;
  initial begin h = new; h.go(); end
endmodule
