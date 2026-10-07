// § paramValRhsSharesParamConst273
interface ifc #(parameter logic [31:0] M = 32'hA5) ();
  logic [31:0] arr [2];
  assign arr[1] = M;
endinterface
module dut (output logic [31:0] o);
  ifc u();
  assign o = u.arr[1];
endmodule
