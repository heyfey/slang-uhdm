// § portViewParamShared164 § modportPortViewParamDef164 — two parent modules, each with its own interface instance and a different value, ordered views of one definition
interface my_if #(parameter W = 2);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_if.mp b);
  assign b.data = '0;
endmodule
module pa;
  my_if #(.W(3)) bus();
  sub u(bus);
endmodule
module pb;
  my_if #(.W(6)) bus();
  sub u(bus);
endmodule
module top;
  pa a();
  pb b();
endmodule
