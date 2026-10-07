// § ifaceGenCaLhsUnbound275 — a plain int parameter value in an interface generate scope
interface ifc #(parameter int P = 9) ();
  logic [31:0] i_gen;
  if (1) begin : gi
    assign i_gen = P;
  end
endinterface
module dut (output logic [31:0] o);
  ifc u ();
  assign o = u.i_gen;
endmodule
