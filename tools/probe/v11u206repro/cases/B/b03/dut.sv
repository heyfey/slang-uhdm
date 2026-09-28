// § tpArrayElemBindsDefDefault206
interface ifc #(parameter int W = 3, parameter type t = logic [W-1:0]);
  t m [4];
endinterface
module b03 (input logic [2:0] i, output logic [2:0] o);
  ifc u ();
  assign u.m[0] = i;
  assign o = u.m[0];
endmodule
