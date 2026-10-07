// § ifaceGenCaLhsUnbound275 — the instantiating module declares the same name: bindVariable finds it there
interface ifc #(parameter int M = 5) ();
  logic [31:0] s;
  if (1) begin : gi
    assign s = M;
  end
endinterface
module dut (output logic [31:0] o);
  logic [31:0] s;
  ifc u ();
  assign s = 1;
  assign o = u.s ^ s;
endmodule
