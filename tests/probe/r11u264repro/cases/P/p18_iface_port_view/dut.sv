// § elabParamRefSignedTsUnlocated264
interface itf #(parameter int A = 16, parameter int B = 32, parameter int C = B) ();
  localparam int LC = C;
  logic [C-1:0] v;
  modport m (output v);
endinterface
module leaf (itf p);
  assign p.v = '0;
endmodule
module top ();
  itf i ();
  leaf u (i);
endmodule
