// § modportPortViewParamDef164 § portViewParamShared164 — interface-array elements connected by name inside a gen-for
interface my_if #(parameter W = 2);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_if.mp b);
  assign b.data = '0;
endmodule
module top;
  my_if #(.W(4)) arr [2] ();
  for (genvar i = 0; i < 2; i++) begin : g
    sub u(.b(arr[i]));
  end
endmodule
