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
  M u(.intf(arr[1]));
endmodule
