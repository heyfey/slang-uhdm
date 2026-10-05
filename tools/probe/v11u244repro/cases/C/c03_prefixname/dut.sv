// § methCallNameSpanAcrossLines244
package p;
  class g;
    function int get(); return 1; endfunction
    function int get_x(); return 2; endfunction
    function int geta(int a); return a; endfunction
  endclass
  class user;
    function void run(g get);
      int z;
      z = get. get_x();
      z = get .get();
      z = get. geta(get.get());
      z = get./*c*/get_x();
      z = get. // tail
          get();
    endfunction
  endclass
endpackage
module top; p::user u; initial u = new(); endmodule
