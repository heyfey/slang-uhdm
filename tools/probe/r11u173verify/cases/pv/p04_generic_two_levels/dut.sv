// § modportPortViewParamDef164 § portViewParamShared164 — a generic interface port passed through two instance levels
interface my_if #(parameter W = 2);
  logic [W-1:0] data;
endinterface
module leaf (interface b);
  assign b.data = '0;
endmodule
module mid (interface b);
  leaf l(.b(b));
endmodule
module top;
  my_if #(.W(5)) bus();
  mid m(.b(bus));
endmodule
