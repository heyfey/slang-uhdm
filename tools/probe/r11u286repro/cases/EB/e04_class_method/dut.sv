// § escBlockNameSpanTrailSpace286 — escaped block names in a class method and a package function
package p;
  class c;
    function int f();
      begin : \cm@1 
        return 1;
      end
    endfunction
  endclass
  function automatic int g();
    begin : \pf@2 
      return 2;
    end
  endfunction
endpackage
module top; import p::*; endmodule
