// § modportPortViewParamDef164 § portViewParamShared164 — `.*` wildcard through two levels, modport port at the leaf
interface my_if #(parameter W = 2);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module leaf (my_if.mp bus);
  assign bus.data = '0;
endmodule
module mid (my_if.mp bus);
  leaf l(.*);
endmodule
module top;
  my_if #(.W(4)) bus();
  mid m(.*);
endmodule
