// § modportPortViewParamDef164 — a generic interface port, named connection through a modport (control: path names kept)
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (interface bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface #(.W(5)) b0();
  sub u0(.bus(b0.mp));
endmodule
