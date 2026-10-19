// § builtinMailboxSpecBare412
package pk;
  mailbox #(int) pm;
endpackage
module top();
  if (1) begin : g
    mailbox #(logic [3:0]) gm;
  end
  mailbox #(int) arr [2];
endmodule
