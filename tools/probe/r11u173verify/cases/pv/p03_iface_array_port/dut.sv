// § modportPortViewParamDef164 § portViewParamShared164 — an interface-array port receiving a whole interface array
interface my_if #(parameter W = 2);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_if.mp b [1:0]);
  assign b[0].data = '0;
  assign b[1].data = '1;
endmodule
module top;
  my_if #(.W(3)) arr [1:0] ();
  sub u(.b(arr));
endmodule
