// § genericPlainNamedView176 § genericMpConnLowConnAtDecl176
interface ConnectTB;
  logic drive;
  logic observe;
  modport dut (input drive, output observe);
  modport tb (output drive, input observe);
endinterface
module M (ConnectTB.tb t, interface h, interface g); initial g.drive = 1; endmodule
module TOP();
  ConnectTB e();
  ConnectTB f();
  logic x;
  M u(.t(e), .h(e), .g(f));
endmodule
