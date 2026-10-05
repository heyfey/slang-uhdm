// § methCallNameSpanAcrossLines244
package p;
  class it; rand int a; endclass
  class user;
    function void run(it x);
      int ok;
      ok = x .randomize();
      ok = x.
           randomize() with { a < 5; };
      x .srandom(3);
    endfunction
  endclass
endpackage
module top; p::user u; initial u = new(); endmodule
