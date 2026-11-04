// § modportPortViewParamDef164 § portViewParamShared164 — ordered modport views of interface-array elements inside a gen-for block
interface my_if #(parameter W = 2);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_if.mp b);
  assign b.data = '1;
endmodule
module top;
  my_if #(.W(3)) arr [2] ();
  for (genvar i = 0; i < 2; i++) begin : g
    sub u(arr[i]);
  end
endmodule
