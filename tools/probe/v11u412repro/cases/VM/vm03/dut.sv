// § builtinMailboxSpecBare412
package pk;
  mailbox #(int) pm;
endpackage
module top;
  std::mailbox #(int) sm;
  semaphore s;
endmodule
