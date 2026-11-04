// § modportPortViewParamDef164 § portViewParamShared164 § tpAnonStructLastParamUser167 — interface header type parameter with a struct default and a value parameter of it, two ordered port views
interface my_if #(parameter type T = struct packed { logic [2:0] a; }, parameter T P = '{a: 3'd5}, parameter W = 2);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_if.mp b);
  assign b.data = '1;
endmodule
module top;
  my_if #(.W(4)) bus();
  sub u0(bus);
  sub u1(bus);
endmodule
