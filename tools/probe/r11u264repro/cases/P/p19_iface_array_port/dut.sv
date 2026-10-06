// § elabParamRefSignedTsUnlocated264
interface itf #(parameter int AW = 16, parameter int VW = AW);
  logic [VW-1:0] v;
  modport mp (input v);
endinterface
module recv (itf.mp p[2]);
endmodule
module top;
  itf arr[2]();
  recv u (.p(arr));
endmodule
