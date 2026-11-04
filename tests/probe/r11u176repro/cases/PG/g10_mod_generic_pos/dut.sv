// § genericPlainNamedView176
interface ConnectTB;
  logic drive;
  logic observe;
  modport dut (input drive, output observe);
  modport tb (output drive, input observe);
endinterface
module TESTBENCH (interface intf);
  initial intf.drive = 0;
endmodule
module TOP();
  ConnectTB conntb();
  TESTBENCH tb(conntb);
endmodule
