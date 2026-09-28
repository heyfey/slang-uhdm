interface ifc #(parameter int W = 2, parameter type t = logic [W-1:0]);
  t [3:0] x;
endinterface
module dut (input logic s, output logic o);
  ifc u();
  assign u.x[0] = s;
  assign o = u.x[0][0];
endmodule
