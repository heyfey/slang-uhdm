// § genericPlainNamedView176 § genericMpConnLowConnAtDecl176
interface ConnectTB;
  logic drive;
  logic observe;
  modport dut (input drive, output observe);
  modport tb (output drive, input observe);
endinterface
module M (interface intf);
  initial intf.drive = 0;
endmodule
module TOP();
  ConnectTB arr [2] ();
  ConnectTB one ();
  M u0(arr[1]);
  M u1(one.tb);
endmodule
