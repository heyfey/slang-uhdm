// § labeledCallStmtLabelDropped415
class C;
  int n;
  task run(int k); n = k; endtask
endclass
module top;
  C h;
  initial begin
    h = new;
    lc: h.run(3);
  end
endmodule
