// r10v173 arm S — SHADOWING and same-span homes.  A formal shadowed by a block
// local; a package variable, a class property and a function local that share a
// name; an out-of-body method; a self-recursive function; a static class
// method; a nested block.  Calls in both spellings from every home.
package sconce_pkg;

  int unsigned rung;                 // package variable
  int unsigned depth = 2;

  function automatic int unsigned step(int unsigned rung);   // formal named `rung`
    return rung + 1;
  endfunction

  function automatic int unsigned shadowed(int unsigned rung);
    int unsigned inner;
    begin : nested_blk
      int unsigned rung2;            // a local in a named block
      rung2 = step(rung) + sconce_pkg::step(rung);
      inner = rung2;
    end
    return inner;
  endfunction

  // self recursion, both spellings inside one body
  function automatic int unsigned spiral(int unsigned n);
    if (n == 0) return 0;
    if (n % 2 == 0) return spiral(n - 1) + 1;
    return sconce_pkg::spiral(n - 1) + 2;
  endfunction

  task automatic climb(input int unsigned n, output int unsigned o);
    o = step(n) + sconce_pkg::step(n) + spiral(n);
  endtask

  class Chandler;
    int unsigned rung;              // property with the same NAME as the pkg var
    int unsigned lit = step(1);     // PROPERTY INITIALIZER call, bare
    int unsigned litq = sconce_pkg::step(2);  // property initializer, qualified
    function new();
      rung = step(0) + sconce_pkg::step(0);
    endfunction
    // in-body method
    function int unsigned inBody(int unsigned rung);
      return step(rung) + sconce_pkg::step(rung);
    endfunction
    // declared here, defined out of body below
    extern function int unsigned outBody(int unsigned rung);
    static function int unsigned statMeth(int unsigned n);
      return step(n) + sconce_pkg::spiral(n);
    endfunction
  endclass

  function int unsigned Chandler::outBody(int unsigned rung);
    return sconce_pkg::step(rung) + step(rung) + this.lit;
  endfunction

endpackage

module sconce_top (output int unsigned s1, output int unsigned s2);
  import sconce_pkg::*;
  Chandler ch;
  int unsigned c1;
  initial begin
    ch = new();
    climb(3, c1);
  end
  assign s1 = shadowed(4) + spiral(5);
  assign s2 = c1 + sconce_pkg::Chandler::statMeth(2);
endmodule
