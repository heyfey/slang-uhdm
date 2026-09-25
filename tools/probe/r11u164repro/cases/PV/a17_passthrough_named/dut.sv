// § modportPortViewParamDef164 — a modport port passed through by name to a child (the child's view keeps path names; the outer element view takes the definition's)
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module inner (my_iface.mp p);
  assign p.data = '0;
endmodule
module recv (my_iface.mp p);
  inner ui (.p(p));
endmodule
module top;
  my_iface #(.W(5)) arr [1:0] ();
  recv u (.p(arr[1]));
endmodule
