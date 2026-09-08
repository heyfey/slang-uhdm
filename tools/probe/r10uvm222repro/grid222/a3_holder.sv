// § ifaceOwnCallCalleeFormRoutes222 — ARM a3, THE HOLDERS.
// The same two callee forms under every HOLDER the arm can be reached from:
// a class in-body method holding a VIRTUAL interface handle (svaunit's
// `svaunit_vpi_wrapper.svh:94`), a class OUT-OF-BODY method, an array of
// virtual handles (the subscripted receiver), and a receiver that is itself a
// CALL (`get_vif().meth()`), which is the one spelling the callee-form gate
// declines that the last-dot split accepted.
class obj22c;
   string p22c;
   function string path22c();
      return p22c;
   endfunction
endclass

interface if22c;
   function void poke22c(string a_name, int a_kind);
   endfunction
endinterface

package pk22c;
   import "DPI-C" context function void dpi22c(input string a_s, input int a_k);
endpackage

class holder22c;
   virtual if22c vif22c;
   virtual if22c bank22c[4];
   obj22c o22c;

   // h01 in-body class method, QUALIFIED callee, PLAIN argument.
   function void h01_plain(string a_s);
      vif22c.poke22c(a_s, 1);
   endfunction

   // h02 in-body class method, QUALIFIED callee, RECEIVER-QUALIFIED argument.
   function void h02_recvarg();
      vif22c.poke22c(o22c.path22c(), 2);
   endfunction

   // h03 in-body class method, SUBSCRIPTED receiver, plain argument.
   function void h03_idx(int a_i, string a_s);
      bank22c[a_i].poke22c(a_s, 3);
   endfunction

   // h04 in-body class method, SUBSCRIPTED receiver, receiver-qualified arg.
   function void h04_idxarg(int a_i);
      bank22c[a_i].poke22c(o22c.path22c(), 4);
   endfunction

   // h05 in-body class method, QUALIFIED callee, argument one body down.
   function void h05_body(int a_i);
      if (a_i > 0) begin
         vif22c.poke22c(o22c.path22c(), 5);
      end
   endfunction

   extern function void h06_oob();
endclass

function void holder22c::h06_oob();
   // h06 OUT-OF-BODY class method, QUALIFIED callee, receiver-qualified arg.
   vif22c.poke22c(o22c.path22c(), 6);
endfunction

module mod22c;
   holder22c hh22c;
   obj22c oo22c;
   if22c u_if22c();

   // h07 MODULE procedural block, QUALIFIED callee, receiver-qualified arg.
   initial begin
      u_if22c.poke22c(oo22c.path22c(), 7);
   end

   // h08 MODULE function, QUALIFIED callee, receiver-qualified argument.
   function void h08_modfn();
      u_if22c.poke22c(oo22c.path22c(), 8);
   endfunction
endmodule
