// § enumTdLastWriter214 § anonMemberTdLastWriter212 — the enum is an anonymous-struct member type in a module (pass 212's writer) and is imported by a second package (the package writer), with a parameter typed by it
package p;
  typedef enum logic [1:0] {A0, A1, A2} e_t;
endpackage
package q;
  import p::*;
  function automatic e_t f(e_t v); return v; endfunction
endpackage
module top(output logic [2:0] o);
  import q::*;
  struct packed { p::e_t m; logic x; } s;
  parameter p::e_t PE = p::A2;
  assign s = '{m: PE, x: 1'b1};
  assign o = s;
endmodule
