// § modportPortViewParamDef164 — modport port, two instances on two array elements (interface_array's shape)
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_iface.mp bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface #(.W(5)) arr [1:0] ();
  sub u0(.bus(arr[0]));
  sub u1(.bus(arr[1]));
endmodule
