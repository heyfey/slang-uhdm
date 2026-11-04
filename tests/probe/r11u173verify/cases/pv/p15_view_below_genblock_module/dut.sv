// § modportPortViewParamDef164 — the view's instance one module level below a gen-if block (its ancestor is in the generate scope)
interface my_if #(parameter W = 2);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_if.mp b);
  assign b.data = '1;
endmodule
module mid (my_if.mp b);
  sub s(b);
endmodule
module top;
  my_if #(.W(3)) bus();
  if (1) begin : g
    mid m(bus);
  end
endmodule
