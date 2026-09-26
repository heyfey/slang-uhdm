// § modportPortViewParamDef164 § tpAnonStructLastParamUser167 § tpAnonStructCopySpanAtKeyword167 — an ordered modport view of an interface with a header parameter AND a body type parameter's anonymous struct used by a value parameter
interface my_if #(parameter W = 2);
  localparam type it_t = struct packed {
    logic [W-1:0] x;
    logic [W-1:0] y;
  };
  localparam it_t I = '{x: 1, y: 2};
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_if.mp b);
  assign b.data = '0;
endmodule
module top;
  my_if #(.W(4)) bus();
  sub u(bus);
endmodule
