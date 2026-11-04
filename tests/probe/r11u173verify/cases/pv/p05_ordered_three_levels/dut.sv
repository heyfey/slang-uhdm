// § modportPortViewParamDef164 § portViewParamShared164 — ordered modport connections through three instance levels
interface my_if #(parameter W = 2);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module l3 (my_if.mp b);
  assign b.data = '1;
endmodule
module l2 (my_if.mp b);
  l3 u(b);
endmodule
module l1 (my_if.mp b);
  l2 u(b);
endmodule
module top;
  my_if #(.W(7)) bus();
  l1 u(bus);
endmodule
