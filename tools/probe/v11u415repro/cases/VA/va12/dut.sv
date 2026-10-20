// § labeledCallStmtLabelDropped415
module top(input logic [7:0] a);
  int r;
  initial begin
    lr: r = $urandom;
    ls: void'($urandom);
    lsr: std::randomize(r);
  end
endmodule
