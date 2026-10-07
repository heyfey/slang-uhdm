// § ifaceGenCaLhsUnbound275 — a plain parameter value read in an interface generate scope
interface ifc #(parameter int M = 5) ();
  logic [31:0] s;
  if (1) begin : gi
    assign s = M;
  end
endinterface
module dut (output logic [31:0] o);
  ifc u ();
  assign o = u.s;
endmodule
