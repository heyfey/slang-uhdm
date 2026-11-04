// § macroCloneLoopVarPerSub449
package p;
  class C;
    function void a(ref byte s[]); foreach (s[i]) s[i] = 0; endfunction
    function void b(ref int s[]); foreach (s[i]) s[i] = 0; endfunction
  endclass
endpackage
package r;
  import p::*;
  int k;
endpackage
package r2;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
  import r2::*;
endmodule
