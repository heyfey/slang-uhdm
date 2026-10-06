// § sgnLitElabFreshIntTs266
interface ifc;
  parameter int P = 12'sd5;
  logic [31:0] v;
  assign v = P;
endinterface
module dut (output logic [31:0] o);
  ifc i();
  assign o = i.v;
endmodule
