// § sysCallEmptyArgIsIntZero401
module top;
  int a;
  string s;
  initial begin s = $sformatf("%d %d", a,); $display(a, , $time); end
endmodule
