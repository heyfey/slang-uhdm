// § ifaceGenCaLhsUnbound275 — two nested generate scopes in an interface
interface ifc #(parameter int M = 9) ();
  logic [31:0] s;
  if (1) begin : ga
    if (1) begin : gb
      assign s = M;
    end
  end
endinterface
module dut (output logic [31:0] o);
  ifc u ();
  assign o = u.s;
endmodule
