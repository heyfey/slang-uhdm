// § modportPortViewParamDef164 § portViewParamShared164 — `.bus` shorthand to a modport port, the interface overriding two parameters
interface my_if #(parameter W = 2, parameter D = 1);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_if.mp bus);
  assign bus.data = '1;
endmodule
module top;
  my_if #(.W(6), .D(3)) bus();
  sub u(.bus);
endmodule
