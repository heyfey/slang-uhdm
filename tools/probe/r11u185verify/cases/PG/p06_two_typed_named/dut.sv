// § progTypedPortLowConnUnlocated176 § progLowConnDefModport176
interface ConnectTB;
  logic drive;
  logic observe;
  modport dut (input drive, output observe);
  modport tb (output drive, input observe);
endinterface
program TESTBENCH (ConnectTB.dut x, ConnectTB.tb y);
  initial begin y.drive = x.drive; x.observe = y.observe; end
endprogram
module TOP();
  ConnectTB c1();
  ConnectTB c2();
  TESTBENCH tb(.y(c2), .x(c1));
endmodule
