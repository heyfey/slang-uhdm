// § progTypedPortLowConnUnlocated176 § progLowConnDefModport176 § progPlainPortViewUnparented176
interface ConnectTB;
  logic drive;
  logic observe;
  modport dut (input drive, output observe);
  modport tb (output drive, input observe);
endinterface
program P (ConnectTB.tb m, ConnectTB t, interface g);
  initial begin m.drive = 0; t.drive = 1; g.drive = 1; end
endprogram
module M (ConnectTB.tb m, ConnectTB t, interface g);
  initial begin m.drive = 0; t.drive = 1; g.drive = 1; end
endmodule
module TOP();
  ConnectTB a();
  ConnectTB b();
  ConnectTB c();
  ConnectTB d();
  ConnectTB e();
  ConnectTB f();
  P p(.m(a), .t(b), .g(c));
  M u(.m(d), .t(e), .g(f));
endmodule
