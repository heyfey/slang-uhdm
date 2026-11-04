// § progLowConnDefModport176 § progTypedPortLowConnUnlocated176
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
  parameter int N = 2;
  ConnectTB c0();
  if (N > 1) begin : g
    TESTBENCH tb(c0);
  end
  for (genvar k = 0; k < N; k++) begin : L
    ConnectTB ck();
    TESTBENCH tbk(.intf(ck));
  end
endmodule
