// r10uvm56 arm a1 — THE WITNESS, reduced out of uvm_registry.svh:259.
// An IN-BODY class method that references its OWN IMPLICIT RETURN VARIABLE in
// the four shapes the brief names: $cast argument, own-name assignment,
// `return <name>`, and a read in a condition.
class base_c;
   int v;
endclass

class der_c extends base_c;
   int w;
endclass

class w1;
   // (1a) $cast(f, y) -- the witness shape.
   function der_c f_cast(base_c y);
      if (!$cast(f_cast, y))
        f_cast = null;
   endfunction

   // (1b) plain own-name assignment.
   function der_c f_assign(der_c y);
      f_assign = y;
   endfunction

   // (1c) `return f` -- reads the return name.
   function der_c f_retname(der_c y);
      f_retname = y;
      return f_retname;
   endfunction

   // (1d) read in a condition.
   function bit f_read(int y);
      f_read = 1'b1;
      if (f_read == 1'b1)
        f_read = 1'b0;
   endfunction
endclass

module a1_top;
   w1 w;
   der_c d;
   initial begin
      w = new();
      d = w.f_assign(null);
   end
endmodule
