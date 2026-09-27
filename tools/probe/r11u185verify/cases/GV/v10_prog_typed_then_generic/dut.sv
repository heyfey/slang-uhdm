// § genericPlainNamedView176 § genericMpConnLowConnAtDecl176 § progPlainPortViewUnparented176
interface ConnectTB;
  logic drive;
  logic observe;
  modport dut (input drive, output observe);
  modport tb (output drive, input observe);
endinterface
program M (ConnectTB t, interface g); initial g.drive = 1; endprogram
module TOP();
  ConnectTB e();
  ConnectTB f();
  logic x;
  M u(.t(e), .g(f));
endmodule
