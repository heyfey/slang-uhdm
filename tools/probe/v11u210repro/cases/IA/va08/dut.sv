// § elabIfArrIdxChainName205 — va08 (v11u210 break probe): the literal-driven interface-array targets sit in a for-generate INSIDE AN INTERFACE body, the interface instantiated in the module
interface bi;
  logic w;
endinterface
interface top_if;
  bi b[2]();
  for (genvar i = 0; i < 2; i++) begin : g
    assign b[i].w = 1'b1;
  end
endinterface
module dut(output logic o);
  top_if t();
  assign o = t.b[1].w;
endmodule
