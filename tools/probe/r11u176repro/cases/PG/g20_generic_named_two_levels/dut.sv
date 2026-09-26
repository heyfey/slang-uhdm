// § genericPlainNamedView176
interface ConnectTB;
  logic drive;
  logic observe;
  modport dut (input drive, output observe);
  modport tb (output drive, input observe);
endinterface
module LEAF (interface intf);
  initial intf.drive = 0;
endmodule
module MID (interface intf);
  LEAF l(.intf(intf));
endmodule
module TOP();
  ConnectTB conntb();
  MID m(.intf(conntb));
endmodule
