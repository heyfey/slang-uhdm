// § modportPortViewParamDef164 § portViewParamShared164 — generic modport ports `interface.mp`, two definitions, ordered
interface a_if #(parameter W = 2);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
interface b_if #(parameter W = 2);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (interface.mp x, interface.mp y);
  assign x.data = '0;
  assign y.data = '1;
endmodule
module top;
  a_if #(.W(3)) a();
  b_if #(.W(5)) b();
  sub u(a, b);
endmodule
