// § progLowConnDefModport176
interface ConnectTB;
  logic drive;
  modport tb (output drive);
endinterface
program TESTBENCH (ConnectTB.tb intf);
  initial intf.drive = 0;
endprogram
module TOP();
  ConnectTB ifs [2] ();
  TESTBENCH tb(.intf(ifs[1]));
endmodule
