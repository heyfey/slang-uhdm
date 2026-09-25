// § evalFuncSelectKeepsCall148
module top #(parameter logic [7:0] P = 8'hA5) (output logic o, output logic q);
  function automatic logic f(); return P[0]; endfunction
  generate if (1) begin : g
    assign o = f();
  end endgenerate
  assign q = f();
endmodule
