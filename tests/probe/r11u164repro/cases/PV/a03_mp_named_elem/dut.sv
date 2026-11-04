// § modportPortViewParamDef164 — modport port, named connection, array element
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_iface.mp bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface #(.W(5)) arr [1:0] ();
  sub u_sub(.bus(arr[0]));
endmodule
