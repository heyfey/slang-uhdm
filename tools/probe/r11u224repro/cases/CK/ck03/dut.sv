// § strLitContOwnerEnd224
module top #(parameter bit C = 1) (output string o);
  localparam string P = C ? "x" : "ab \
cd";
  assign o = P;
endmodule
