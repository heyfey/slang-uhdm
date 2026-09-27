// § progLowConnDefModport176 § progTypedPortLowConnUnlocated176
interface PI #(parameter int W = 2);
  logic [W-1:0] drive;
  logic [W-1:0] observe;
  modport tb (output drive, input observe);
endinterface
program TESTBENCH (PI.tb intf);
  initial intf.drive = '1;
endprogram
module TOP();
  PI #(.W(4)) c4();
  PI #(.W(8)) c8();
  TESTBENCH t4(c4);
  TESTBENCH t8(c8);
endmodule
