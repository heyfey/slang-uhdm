// § progTypedPortLowConnUnlocated176
interface ConnectTB;
  logic drive;
  modport tb (output drive);
endinterface
program TESTBENCH (ConnectTB.tb intf);
  initial intf.drive = 0;
endprogram
module TOP();
  ConnectTB intf();
  TESTBENCH tb(.*);
endmodule
