// § vifTdRefVarLocalImplicitNet481
module top;
  initial begin semaphore s; s = new(1); s.get(1); s.put(1); end
endmodule
