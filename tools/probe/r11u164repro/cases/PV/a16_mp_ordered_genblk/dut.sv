// § modportPortViewParamDef164 — a modport port, named connection inside a generate block to an outer instance
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_iface.mp bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface #(.W(5)) b0();
  if (1) begin : g
    sub u0(.bus(b0));
  end
endmodule
