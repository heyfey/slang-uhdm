// § progLowConnDefModport176
interface ConnectTB;
  logic drive;
  logic observe;
  modport dut (input drive, output observe);
  modport tb (output drive, input observe);
endinterface
module DUT (ConnectTB.dut intf);
  assign intf.observe = intf.drive;
endmodule
program TESTBENCH (ConnectTB.tb intf);
  initial intf.drive = 0;
endprogram
module TOP();
  ConnectTB conntb();
  DUT d(conntb);
  TESTBENCH tb(conntb);
endmodule
