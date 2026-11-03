// § vifTdRefVarLocalImplicitNet481
module top;
  initial begin mailbox m; m = new(); m.put(1); end
endmodule
