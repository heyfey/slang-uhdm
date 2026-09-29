// § strLitContOwnerEnd224
module top #(parameter bit C = 0) (output string o);
  for (genvar g = 0; g < 2; g++) begin : gb
    string q;
    always_comb q = C ? "x" : "ab \
cd";
  end
  assign o = gb[0].q;
endmodule
