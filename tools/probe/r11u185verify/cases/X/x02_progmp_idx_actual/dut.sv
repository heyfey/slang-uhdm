// § hierPathSelIdxAtPath178 § progLowConnDefModport176
interface ConnectTB;
  logic drive;
  logic observe;
  modport dut (input drive, output observe);
  modport tb (output drive, input observe);
endinterface
program TESTBENCH (ConnectTB.tb intf);
  initial intf.drive = 0;
endprogram
module TOP();
  localparam int K = 2;
  ConnectTB arr [3] ();
  TESTBENCH t0(arr[K-1]);
  TESTBENCH t1(.intf(arr[K]));
endmodule
