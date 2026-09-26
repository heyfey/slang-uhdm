// § genericMpConnLowConnAtDecl176
interface ConnectTB;
  logic drive;
  modport tb (output drive);
endinterface
program TESTBENCH (interface intf);
  initial intf.drive = 0;
endprogram
module TOP();
  ConnectTB intf();
  TESTBENCH tb(.intf);
endmodule
