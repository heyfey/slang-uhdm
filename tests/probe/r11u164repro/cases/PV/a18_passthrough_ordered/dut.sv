// § modportPortViewParamDef164 — a modport port passed through by position to a child
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module inner (my_iface.mp p);
  assign p.data = '0;
endmodule
module recv (my_iface.mp p);
  inner ui (p);
endmodule
module top;
  my_iface #(.W(5)) b ();
  recv u (b);
endmodule
