// r10uvm56 arm a7 — the RECURSIVE / SELF-CALL case, where the name is BOTH the
// return variable and the function.  `f = f(x-1)` has the name on both sides of
// one assignment.
class c7;
   function automatic int r_self(int y);
      if (y <= 0)
        r_self = 0;
      else
        r_self = r_self(y - 1) + 1;
   endfunction
endclass

module a7_top;
   function automatic int m_self(int y);
      if (y <= 0)
        m_self = 0;
      else
        m_self = m_self(y - 1) + 1;
   endfunction

   int r;
   c7 h;
   initial begin
      h = new();
      r = m_self(3) + h.r_self(3);
   end
endmodule
