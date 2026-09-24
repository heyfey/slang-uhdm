// r10uvm56 arm a5 — the return variable USED AS AN ARGUMENT, in every position
// a naive fix could over- or under-fire on: a SYSTEM function ($cast -- the
// witness), a PLAIN function call, a TASK call as output and as inout, and as
// the LVALUE of a plain assignment.  Class IN-BODY scope and module scope both.
class base_c;
   int v;
endclass
class der_c extends base_c;
   int w;
endclass

class c5;
   function int helper(int y);
      helper = y;
   endfunction
   // NOTE: a TASK cannot be invoked from a function (LRM; slang rejects it and
   // so the arm would not build), so the output/inout ARGUMENT POSITIONS are
   // exercised with FUNCTIONS carrying output/inout formals, which is the same
   // argument position for the purposes of the binding rule.
   function void fout(output int o);
      o = 7;
   endfunction
   function void finout(inout int io);
      io = io + 1;
   endfunction

   // (5a) system-function argument -- the witness
   function der_c a_sys(base_c y);
      if (!$cast(a_sys, y))
        a_sys = null;
   endfunction
   // (5b) plain method-call argument
   function int a_call(int y);
      a_call = y;
      a_call = helper(a_call);
   endfunction
   // (5c) task OUTPUT argument
   function int a_tout(int y);
      a_tout = y;
      fout(a_tout);
   endfunction
   // (5d) task INOUT argument
   function int a_tinout(int y);
      a_tinout = y;
      finout(a_tinout);
   endfunction
   // (5e) plain-assignment lvalue (already in a1, repeated here for the grid)
   function int a_lval(int y);
      a_lval = y;
   endfunction
endclass

module a5_top;
   function int m_helper(int y);
      m_helper = y;
   endfunction
   function void m_fout(output int o);
      o = 7;
   endfunction
   function void m_finout(inout int io);
      io = io + 1;
   endfunction

   function der_c b_sys(base_c y);
      if (!$cast(b_sys, y))
        b_sys = null;
   endfunction
   function int b_call(int y);
      b_call = y;
      b_call = m_helper(b_call);
   endfunction
   function int b_tout(int y);
      b_tout = y;
      m_fout(b_tout);
   endfunction
   function int b_tinout(int y);
      b_tinout = y;
      m_finout(b_tinout);
   endfunction
   function int b_lval(int y);
      b_lval = y;
   endfunction

   int r;
   c5 h;
   initial begin
      h = new();
      r = b_call(1) + b_tout(1) + b_tinout(1) + b_lval(1) +
          h.a_call(1) + h.a_tout(1) + h.a_tinout(1) + h.a_lval(1);
   end
endmodule
