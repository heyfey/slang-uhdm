// § genericMpConnLowConnAtDecl176 § progLowConnDefModport176 § progPlainPortViewUnparented176
interface ConnectTB;
  logic drive;
  logic observe;
  modport dut (input drive, output observe);
  modport tb (output drive, input observe);
endinterface
program TESTBENCH (interface intf, interface plain);
  initial begin intf.drive = 0; plain.drive = 1; end
endprogram
module TOP();
  ConnectTB arr [3] ();
  TESTBENCH tb(.intf(arr[2].tb), .plain(arr[0]));
endmodule
