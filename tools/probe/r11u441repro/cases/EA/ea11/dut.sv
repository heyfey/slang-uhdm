// § sysCallEmptyArgEndPrevTok441
module top;
  parameter P = 3;
  int a = 1;
  always @(a) begin
    $display("## P = %-d;", P
             ," a = %-d;", a,
             ," end ");
  end
endmodule
