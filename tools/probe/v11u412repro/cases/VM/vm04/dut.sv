// § builtinMailboxSpecBare412
class mailbox_user #(type T = int);
  T v;
endclass
module top;
  mailbox_user #(int) mu;
  mailbox #(mailbox_user #(int)) mm;
endmodule
