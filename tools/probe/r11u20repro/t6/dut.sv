// t6: INTERFACE, NON-ANSI module header, and a module-BODY type parameter.
interface ifc #(parameter int IW = 4, parameter type IT = logic [IW-1:0]) ();
  logic [IW-1:0] w;
endinterface
module nonansi (o);
  output logic o;
  parameter  int  NW = 7;
  parameter  type NT = logic [NW-1:0];
  localparam type ML = logic [NW-1:0];
  NT n; ML m;
  assign o = ^{n,m};
endmodule
module dut (output logic o);
  ifc i0 ();
  nonansi u0 (.o(o));
endmodule
