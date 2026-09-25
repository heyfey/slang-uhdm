// § psBoundBareRefByBase145
interface ifc;
  logic [15:0] d;
  modport m(input d);
endinterface
module c(ifc.m bus, output logic [4:0] o);
  localparam int H = 8;
  localparam int L = 4;
  assign o = bus.d[H:L];
endmodule
module dut(output logic [4:0] o);
  ifc u();
  assign u.d = 16'h1234;
  c k(.bus(u), .o(o));
endmodule
