// § sgnLitElabFreshIntTs266
interface ifc;
  localparam int P = 12'shFFF;
  logic [63:0] w;
  assign w = P;
endinterface
module dut (output logic [63:0] o);
  ifc i0 ();
  assign o = i0.w;
endmodule
