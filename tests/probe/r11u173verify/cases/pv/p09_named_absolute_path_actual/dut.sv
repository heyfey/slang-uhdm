// § modportPortViewParamDef164 § portViewParamShared164 — a named connection whose actual is an absolute hierarchical name (`.b(top.bus)`)
interface my_if #(parameter W = 2);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_if.mp b);
  assign b.data = '0;
endmodule
module top;
  my_if #(.W(5)) bus();
  sub u(.b(top.bus));
endmodule
