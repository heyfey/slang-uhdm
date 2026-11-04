// § progTypedPortLowConnUnlocated176
interface ConnectTB #(parameter W = 2);
  logic [W-1:0] drive;
  modport tb (output drive);
endinterface
program TESTBENCH (ConnectTB.tb intf);
  initial intf.drive = '0;
endprogram
module TOP();
  ConnectTB #(.W(5)) conntb();
  TESTBENCH tb(.intf(conntb));
endmodule
