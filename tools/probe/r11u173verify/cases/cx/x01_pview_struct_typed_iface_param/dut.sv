// § modportPortViewParamDef164 § tpAnonStructLastParamUser167 — port view (ordered, modport) of an interface whose value parameter has a type parameter's anonymous struct
interface my_if;
  localparam type it_t = struct packed {
    logic [3:0] x;
    logic [3:0] y;
  };
  localparam it_t I = '{x: 4'd1, y: 4'd2};
  logic [3:0] data;
  modport mp(output data);
endinterface
module sub (my_if.mp b);
  assign b.data = '0;
endmodule
module top;
  my_if bus();
  sub u(bus);
endmodule
