// b06: import shapes -- wildcard, explicit item, re-export, two importers,
// package param read from a class, package imported into a package.
package b06_a;
  parameter A_H = 'h1a;
  parameter A_D = 'd26;
  parameter A_S = 'sh1a;
endpackage
package b06_b;
  import b06_a::*;
  export b06_a::*;
  parameter B_H = 'h2b;
endpackage
module b06_m1;
  import b06_a::A_H;
  initial $display(A_H);
endmodule
module b06_m2;
  import b06_a::*;
  initial $display(A_H, A_D, A_S);
endmodule
module b06_m3;
  import b06_b::*;
  initial $display(B_H);
endmodule
package b06_c;
  import b06_a::*;
  class b06_cls;
    function int f(); return A_H + A_D; endfunction
  endclass
endpackage
module b06_top;
  b06_m1 x1();
  b06_m2 x2();
  b06_m3 x3();
endmodule
