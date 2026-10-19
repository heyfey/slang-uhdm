// § builtinMailboxSpecBare412
class C;
  mailbox #(string) q;
  function void f();
    mailbox #(bit [3:0]) loc;
  endfunction
endclass
module top;
  C c;
endmodule
