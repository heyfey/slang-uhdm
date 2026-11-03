// § vifTdRefVarLocalImplicitNet481
module top; int x;
  initial begin mailbox #(int) m; m = new(); m.put(1); m.get(x); end
endmodule
