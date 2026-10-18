// § sysCallEmptyArgIsIntZero401
module top();
  initial begin
    $write(1,,2);
    $fdisplay(1, 2,,3);
  end
endmodule
