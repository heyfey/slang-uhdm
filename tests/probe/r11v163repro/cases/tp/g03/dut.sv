// § elabTpDefaultDefNamed163
interface ifc #(parameter int W = 4, parameter type t_t = logic [W-1:0]) ();
  t_t d;
endinterface
module top;
  ifc #(.W(5)) i();
  assign i.d = '1;
endmodule
