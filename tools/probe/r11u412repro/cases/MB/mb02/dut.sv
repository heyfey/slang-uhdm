// § builtinMailboxSpecBare412
class C;
  mailbox #(int) q;
  function void f();
    mailbox #(byte) l;
    l = new();
  endfunction
endclass
module top();
  C c;
endmodule
