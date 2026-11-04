// § genProcFoldDeclTsScopeNamed167 — the parameter read by a generate-scope CONTINUOUS assignment (not a process: control)
module top #(parameter int W = 4, parameter logic [W-1:0] Z = 4'd6) (output logic [W-1:0] q);
  if (1) begin : g
    assign q = Z;
  end
endmodule
