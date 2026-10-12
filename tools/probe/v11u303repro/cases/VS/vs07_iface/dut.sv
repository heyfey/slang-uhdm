// § sysCallArgRefScopedName303
interface ifc #(parameter int N = 8);
  logic [7:0] v;
  for (genvar k = 0; k < $clog2(N); k++) begin : g
    assign v[k] = 1'b0;
  end
endinterface
module dut (output logic o);
  ifc u ();
  assign o = u.v[0];
endmodule
