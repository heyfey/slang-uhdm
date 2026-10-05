// § lawSStringTd243
// task formals of a string typedef: input, output, ref, inout, with a default
package p;
  typedef string str_t;
  task automatic t(input str_t a = "d", output str_t b, ref str_t c, inout str_t e);
    b = a; c = a; e = a;
  endtask
endpackage
module top;
  import p::*;
  str_t x, y, z;
  initial t("a", x, y, z);
endmodule
