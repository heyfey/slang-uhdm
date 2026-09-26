// § progLowConnDefModport176
interface ConnectTB;
  logic drive;
  logic observe;
  modport tb (output drive, input observe);
endinterface
program TESTBENCH (ConnectTB.tb intf);
  logic seen;
  initial begin intf.drive = 0; seen = intf.observe; end
endprogram
module env();
  ConnectTB c();
  TESTBENCH tb(c);
endmodule
module TOP();
  env e1();
  env e2();
endmodule
