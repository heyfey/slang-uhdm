// § paramValRhsSharesParamConst273
interface ifc;
  localparam int unsigned M = 17;
  logic [31:0] arr [2];
  assign arr[0] = M;
  assign arr[1] = '0;
endinterface
module dut (output logic [31:0] o);
  ifc i0();
  assign o = i0.arr[0];
endmodule
