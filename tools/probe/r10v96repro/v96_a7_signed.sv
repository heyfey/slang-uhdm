// r10v96 arm 7 — signedness and parameter-typed casts.
package v96p7;
  parameter int PN = 12;
  parameter type T = int;
  function automatic void f7();
    logic [31:0] v;
    int          i;
    i = int'(v);
    i = integer'(v);
    i = PN'(v);                  // parameter-valued SIZE cast
    i = T'(v);                   // parameter-TYPE cast
    i = int'($signed(v));
    i = integer'($unsigned(v));
    i = longint'(-3);
    i = shortint'(-3);
    i = byte'(-3);
    $display("%0d", i);
  endfunction
endpackage

module v96m7 #(parameter type TT = shortint, parameter int NB = 7);
  logic [31:0] v;
  int i;
  initial begin
    i = TT'(v);
    i = NB'(v);
    i = integer'(v);
  end
endmodule
