// § progLowConnDefModport176
interface ConnectTB;
  logic drive;
  logic observe;
  modport dut (input drive, output observe);
  modport tb (output drive, input observe);
endinterface
program TESTBENCH (ConnectTB.tb intf);
  initial intf.drive = 0;
endprogram
module MID();
  ConnectTB conntb();
  TESTBENCH tb(conntb);
endmodule
module TOP();
  MID m();
endmodule
