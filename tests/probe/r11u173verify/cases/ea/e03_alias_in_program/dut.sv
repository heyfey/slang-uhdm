// § enumAliasClone161 — an alias of a package enum inside a program block
package pp;
  typedef enum logic [2:0] { R = 3'd1, G = 3'd2, U = 3'd4 } c_e;
endpackage
program prg(output logic [2:0] o);
  typedef pp::c_e my_c;
  my_c v;
  initial begin
    v = pp::G;
    o = v;
  end
endprogram
module top(output logic [2:0] o);
  prg p(.o(o));
endmodule
