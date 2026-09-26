// § modportPortViewParamDef164 — an interface localparam derived from its parameter, ordered modport connection
interface my_if #(parameter W = 2);
  localparam int W2 = W * 2;
  logic [W2-1:0] data;
  modport mp(output data);
endinterface
module sub (my_if.mp b);
  assign b.data = '0;
endmodule
module top;
  my_if #(.W(3)) bus();
  sub u(bus);
endmodule
