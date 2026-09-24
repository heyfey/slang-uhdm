// does the shell reach a SYSTEM call / a built-in method at all?  Both spellings
// with an unbindable argument, and the same with a receiver that is itself a
// dotted chain, so the emitter's statement-position sys arm is exercised.
package Pc6;
  class Sy6 #(type PT = int);
    PT tp; int kk; string ss; int q[$];
    function void D1(); $display("x%0d", tp.conv(kk)); endfunction
    function void D2(); $write(tp.conv(kk));           endfunction
    function void D3(); $fatal(0, tp.conv(kk));        endfunction
    function void D4(); ss = $sformatf("%0d", tp.conv(kk)); endfunction
    function void D5(); $swrite(ss, tp.conv(kk));      endfunction
  endclass
endpackage
