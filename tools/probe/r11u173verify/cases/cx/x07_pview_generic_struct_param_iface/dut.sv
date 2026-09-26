// § modportPortViewParamDef164 § tpAnonStructCopySpanAtKeyword167 — generic port view of an interface with a body type parameter, a value parameter and a port of the type
interface my_if #(parameter W = 3);
  localparam type it_t = struct packed {
    logic [W-1:0] x;
  };
  localparam it_t I = '{x: 1};
  it_t data;
endinterface
module sub (interface b);
  assign b.data = '0;
endmodule
module top;
  my_if #(.W(5)) bus();
  sub u(.b(bus));
endmodule
