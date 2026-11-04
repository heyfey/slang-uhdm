// § portViewParamShared164 — two ordered modport views of one definition
interface my_iface #(parameter W = 3, parameter V = 2);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module subm (my_iface.mp bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface #(.W(5)) b0();
  my_iface #(.W(5)) b1();
  subm u0(b0);
  subm u1(b1);
endmodule
