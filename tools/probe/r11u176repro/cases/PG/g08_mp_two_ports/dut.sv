// § progLowConnDefModport176
interface ConnectTB;
  logic drive;
  logic observe;
  modport dut (input drive, output observe);
  modport tb (output drive, input observe);
endinterface
program TESTBENCH (ConnectTB.tb intf, input logic clk);
  initial intf.drive = clk;
endprogram
module TOP();
  logic clk;
  ConnectTB conntb();
  TESTBENCH tb(conntb, clk);
endmodule
