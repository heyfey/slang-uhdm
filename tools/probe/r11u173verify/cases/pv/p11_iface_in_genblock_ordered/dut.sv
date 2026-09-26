// § modportPortViewParamDef164 § portViewParamShared164 — interface instance and its ordered modport view both inside a gen-if block
interface my_if #(parameter W = 2);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_if.mp b);
  assign b.data = '1;
endmodule
module top;
  if (1) begin : g
    my_if #(.W(3)) bus();
    sub u(bus);
  end
endmodule
