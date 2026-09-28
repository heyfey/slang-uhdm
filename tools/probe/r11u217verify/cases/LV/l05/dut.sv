// § tfItemInitLocalAtType209 — r11u217 l05: initialized locals in functions WITH parentheses (block-item form, the law must not fire), a const local and a static local in a paren-less function, and an interface function in tf-item form
interface ifc;
  logic w;
  function logic fi;
    input logic a;
    logic t = 1'b1;
    return a & t;
  endfunction
endinterface
package p;
  function int f1();
    int x = 1;
    return x;
  endfunction
  function int f2;
    const int y = 2;
    static int z = 3;
    return y + z;
  endfunction
endpackage
module top (output int o, output logic q);
  ifc i();
  assign i.w = 1'b1;
  assign o = p::f1() + p::f2();
  assign q = i.fi(i.w);
endmodule
