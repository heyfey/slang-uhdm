// § hpFnStaticTrailScopeJoin246
package p;
  class c;
    task automatic t();
      static int st;
      st = st + 1;
    endtask
    function void use_it(output int o);
      o = t.st;
    endfunction
  endclass
endpackage
module top;
endmodule
