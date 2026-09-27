// § progLowConnDefModport176 § progTypedPortLowConnUnlocated176
interface ConnectTB;
  logic drive;
  logic observe;
  modport dut (input drive, output observe);
  modport tb (output drive, input observe);
endinterface
program TESTBENCH (ConnectTB.tb a, ConnectTB b);
  initial begin a.drive = 0; b.drive = a.observe; end
endprogram
module TOP();
  ConnectTB c1();
  ConnectTB c2();
  TESTBENCH tb(c1, c2);
endmodule
