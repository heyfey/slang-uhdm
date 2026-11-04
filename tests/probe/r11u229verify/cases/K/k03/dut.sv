// § strLitContOwnerEnd224 (a header parameter's conditional default ending at a continued literal)
module top #(parameter bit C = 1, parameter string P = C ? "x" : "ab \
cd") (output string o);
  assign o = P;
endmodule
