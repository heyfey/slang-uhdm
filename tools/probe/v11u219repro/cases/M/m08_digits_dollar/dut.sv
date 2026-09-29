// § ppIdentEndInRebuiltText219 — forwarded method names with digits, a dollar sign and one character
`define DO_C(CB,M1,M2,M3) \
   begin \
     CB cb = null; \
     if (cb != null) begin \
       cb.M1; \
       cb.M2; \
       cb.M3; \
     end \
   end
`define DO_B(CB,M1,M2,M3) \
  `DO_C(CB,M1,M2,M3)
package p;
class cb_c;
  function void st2ch(int a); endfunction
  function void a$b(); endfunction
  function void q(); endfunction
endclass
class user_c;
  function void run(int x);
    `DO_B(cb_c, st2ch(x), a$b(), q())
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
