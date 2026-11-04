// § vifTdRefVarLocalImplicitNet481
module top;
  initial begin process p; p = process::self(); p.kill(); end
endmodule
