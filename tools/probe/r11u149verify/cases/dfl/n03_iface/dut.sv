// § defaultFillOneConstant140
interface ifc;
  parameter int A [3] = '{default: 7};
  logic [31:0] x;
  assign x = A[1];
endinterface
module dut(output logic [31:0] o);
  ifc u();
  assign o = u.x;
endmodule
