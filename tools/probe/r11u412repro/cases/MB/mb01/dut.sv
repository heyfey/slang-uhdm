// § builtinMailboxSpecBare412
module top();
mailbox #(string) m;
mailbox #(int) n = new();
mailbox p;
initial begin
  string msg = "abc";
  m = new();
  m.put(msg);
end
endmodule
