// r10uvm56 arm a2 — THE POSITIVE CONTROL.  The SAME four shapes as a1, on an
// ORDINARY FUNCTION LOCAL instead of the implicit return variable.  Golden
// binds these; if a fix touches them the law is too wide.
class base_c;
   int v;
endclass

class der_c extends base_c;
   int w;
endclass

class w2;
   function der_c g_cast(base_c y);
      der_c loc;
      if (!$cast(loc, y))
        loc = null;
      g_cast = loc;
   endfunction

   function der_c g_assign(der_c y);
      der_c loc;
      loc = y;
      g_assign = loc;
   endfunction

   function der_c g_retlocal(der_c y);
      der_c loc;
      loc = y;
      return loc;
   endfunction

   function bit g_read(int y);
      bit loc;
      loc = 1'b1;
      if (loc == 1'b1)
        loc = 1'b0;
      g_read = loc;
   endfunction
endclass

module a2_top;
   w2 w;
   initial begin
      w = new();
      void'(w.g_read(1));
   end
endmodule
