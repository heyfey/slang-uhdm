// § ifaceGenCaLhsUnbound275 — a function's returned literal folded in an interface generate scope
interface ifc ();
  function automatic int f(); return 7; endfunction
  logic [31:0] s;
  if (1) begin : gi
    assign s = f();
  end
endinterface
module dut (output logic [31:0] o);
  ifc u ();
  assign o = u.s;
endmodule
