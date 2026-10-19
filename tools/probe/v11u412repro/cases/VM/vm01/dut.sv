// § builtinMailboxSpecBare412
module top;
  mailbox m;
  mailbox #(int) mi = new();
  initial mi.put(3);
endmodule
