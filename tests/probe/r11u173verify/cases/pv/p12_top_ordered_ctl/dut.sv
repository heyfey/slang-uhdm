// § modportPortViewParamDef164 — control of p13-p16: a top-level ordered modport view (no generate scope)
interface my_if #(parameter W = 2);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_if.mp b);
  assign b.data = '1;
endmodule
module top;
  my_if #(.W(3)) bus();
  sub u(bus);
endmodule
