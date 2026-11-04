// § modportPortViewParamDef164 — the ordered modport view's instance inside a gen-if block, the interface instance outside it
interface my_if #(parameter W = 2);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_if.mp b);
  assign b.data = '1;
endmodule
module top;
  my_if #(.W(3)) bus();
  if (1) begin : g
    sub u(bus);
  end
endmodule
