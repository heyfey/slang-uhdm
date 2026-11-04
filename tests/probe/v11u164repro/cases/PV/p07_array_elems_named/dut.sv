// § modportPortViewParamDef164 § portViewParamShared164 — interface array elements behind named modport connections
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_iface.mp bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface #(.W(2)) arr[2]();
  sub u0(.bus(arr[0]));
  sub u1(.bus(arr[1]));
endmodule
