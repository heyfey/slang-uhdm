// § paramValRhsSharesParamConst273
interface ifc #(parameter int unsigned M = 12) ();
  logic [31:0] arr [2];
  assign arr[0] = M;
endinterface
module dut (output logic [31:0] o);
  ifc u();
  assign o = u.arr[0];
endmodule
