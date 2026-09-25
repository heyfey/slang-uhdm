// § modportPortViewParamDef164 — an ordered modport view whose receiving module declares a same-named parameter (the param_assign reads the receiver's value)
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module recv #(parameter W = 7) (my_iface.mp p);
  assign p.data = '0;
endmodule
module top;
  my_iface #(.W(5)) b ();
  recv u (b);
endmodule
