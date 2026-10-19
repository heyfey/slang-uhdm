// § elabVarSysCallInit412
interface ifc;
  int r = $urandom();
endinterface
module top(output logic [31:0] o);
  ifc i();
  for (genvar g = 0; g < 2; g++) begin : gb
    int s = $random;
  end
  assign o = gb[0].s;
endmodule
