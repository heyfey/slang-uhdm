// § classScopeTdRetBuildsOwner206 § namedUnlinkedWrittenOrder207 (a named call, out of formal order, to an extern method returning another class's typedef, before its body)
package p;
  class C #(type T = int); T v; endclass
  class K; typedef C #(byte) q_t; endclass
  class D;
    extern function K::q_t mk(int a, int b = 1, int c = 2);
    extern function void useit(int x);
  endclass
  function void D::useit(int x);
    K::q_t h;
    h = mk(.c(x), .a(1));
    h = mk(.b(x), .c(0), .a(2));
  endfunction
  function K::q_t D::mk(int a, int b = 1, int c = 2);
    return null;
  endfunction
endpackage
module top; endmodule
