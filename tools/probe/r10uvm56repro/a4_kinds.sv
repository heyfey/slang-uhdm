// r10uvm56 arm a4 — EXPLICIT `return` vs OWN-NAME ASSIGNMENT, a VOID function,
// and a TASK (no return variable at all).  Each shape once at class IN-BODY
// scope (the witness scope) and once at module scope (the control scope).
class c4;
   // own-name assignment only
   function int k_assign(int y);
      k_assign = y;
   endfunction
   // explicit return only -- NO reference to the return name exists
   function int k_return(int y);
      return y + 1;
   endfunction
   // both
   function int k_both(int y);
      k_both = y;
      return k_both + 1;
   endfunction
   // void function: no return variable
   function void k_void(int y);
      int loc;
      loc = y;
   endfunction
   // task: no return variable
   task k_task(int y);
      int loc;
      loc = y;
   endtask
endclass

module a4_top;
   function int t_assign(int y);
      t_assign = y;
   endfunction
   function int t_return(int y);
      return y + 1;
   endfunction
   function int t_both(int y);
      t_both = y;
      return t_both + 1;
   endfunction
   function void t_void(int y);
      int loc;
      loc = y;
   endfunction
   task t_task(int y);
      int loc;
      loc = y;
   endtask

   int r;
   c4 h;
   initial begin
      h = new();
      r = t_assign(1) + t_both(1) + h.k_assign(1) + h.k_both(1);
      t_void(1);
      t_task(1);
      h.k_void(1);
      h.k_task(1);
   end
endmodule
