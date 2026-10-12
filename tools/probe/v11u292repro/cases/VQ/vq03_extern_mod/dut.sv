// § pkgVarLvalueScopeSep292
package p; int q; endpackage
module top;
  class c;
    extern function void h();
    task automatic t(); p::q = 4; endtask
  endclass
  function void c::h(); p::q = 2; endfunction
  function automatic void mf(); p::q = 7; endfunction
  always_comb p::q = 1;
  initial begin : blk p::q = 5; end
endmodule
