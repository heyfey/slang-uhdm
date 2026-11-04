// § genericMpConnLowConnAtDecl176 § progPlainPortViewUnparented176 § progLowConnDefModport176
interface ConnectTB;
  logic drive;
  logic observe;
  modport dut (input drive, output observe);
  modport tb (output drive, input observe);
endinterface
program TESTBENCH (interface a, interface b);
  initial begin a.drive = 1; b.drive = 0; end
endprogram
module TOP();
  ConnectTB c1();
  ConnectTB c2();
  TESTBENCH tb(.a(c1.tb), .b(c2));
endmodule
