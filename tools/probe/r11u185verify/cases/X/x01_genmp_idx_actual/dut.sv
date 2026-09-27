// § hierPathSelIdxAtPath178 § genericMpConnLowConnAtDecl176
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
  localparam int K = 2;
  ConnectTB arr [3] ();
  M u0(.intf(arr[K-1].tb));
  M u1(.intf(arr[K].tb));
endmodule
