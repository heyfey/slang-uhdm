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
module TOP();
  ConnectTB c1();
  ConnectTB c2();
  TESTBENCH tb1(c1);
  TESTBENCH tb2(c2);
endmodule
