// § ifaceGenCaLhsUnbound275 — CONTROL: a module generate scope binds the module's signal
module sub #(parameter int M = 5) (output logic [31:0] o);
  logic [31:0] s;
  if (1) begin : gi
    assign s = M;
  end
  assign o = s;
endmodule
module dut (output logic [31:0] o);
  sub u (.o(o));
endmodule
