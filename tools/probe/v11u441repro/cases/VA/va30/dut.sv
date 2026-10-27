// § sysCallEmptyArgEndPrevTok441
interface ifc;
  int a = 1, b = 2;
  initial begin
    $display("x", a,
             , b);
  end
endinterface
module top;
  ifc u();
endmodule
