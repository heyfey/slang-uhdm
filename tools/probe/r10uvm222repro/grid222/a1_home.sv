// § ifaceOwnCallCalleeFormRoutes222 — ARM a1, THE CORPUS FACE.
// An interface's OWN subroutine, called BARE from another subroutine of the
// same interface, with arguments of every form.  The question the arm asks is
// whether the ARGUMENT's spelling can change the CALL STATEMENT's own kind.
// svaunit's `control_assertion_dpi(a_sva.get_sva_path(), ..., $time())` is
// cell c02; `control_assertion_dpi("", ..., $time())` is cell c01.
class obj222;
   string p222;
   function string path222();
      return p222;
   endfunction
   function int num222();
      return 7;
   endfunction
endclass

interface if222;
   obj222 pool222[4];

   function void ctrl222(string a_name, int a_kind, int a_t);
   endfunction

   function void two222(int a_x, int a_y);
   endfunction

   // c01 BARE callee, LITERAL first argument, no dot anywhere.
   function void c01_lit(int a_t);
      ctrl222("", 1, a_t);
   endfunction

   // c02 BARE callee, RECEIVER-QUALIFIED METHOD CALL as first argument.
   //     THE CORPUS FACE (svaunit_vpi_interface.sv:310/334/358/383/408/434).
   function void c02_recvcall(obj222 a_o, int a_t);
      ctrl222(a_o.path222(), 2, a_t);
   endfunction

   // c03 BARE callee, PLAIN DOTTED NAME as first argument (no call).
   function void c03_dotname(obj222 a_o, int a_t);
      ctrl222(a_o.p222, 3, a_t);
   endfunction

   // c04 BARE callee, INDEXED-RECEIVER method call as first argument.
   //     (svaunit_vpi_interface.sv:512 `cover_info[index].get_sva_name()`.)
   function void c04_idxrecv(int a_i, int a_t);
      ctrl222(pool222[a_i].path222(), 4, a_t);
   endfunction

   // c05 BARE callee, receiver-qualified call in the SECOND argument only.
   function void c05_second(obj222 a_o, int a_t);
      two222(a_t, a_o.num222());
   endfunction

   // c06 BARE callee, receiver-qualified call in the LAST argument.
   function void c06_last(obj222 a_o);
      ctrl222("", 6, a_o.num222());
   endfunction

   // c07 BARE callee, two receiver-qualified call arguments.
   function void c07_two(obj222 a_o);
      two222(a_o.num222(), a_o.num222());
   endfunction

   // c08 BARE callee, receiver-qualified argument, in EXPRESSION position.
   function int c08_expr(obj222 a_o);
      return fn222(a_o.num222());
   endfunction

   function int fn222(int a_x);
      return a_x;
   endfunction

   // c09 BARE callee, receiver-qualified argument, one control body down.
   function void c09_body(obj222 a_o, int a_t);
      if (a_t > 0) begin
         ctrl222(a_o.path222(), 9, a_t);
      end
   endfunction

   // c10 BARE callee, argument is a SYSTEM call with no dot.
   function void c10_sys(int a_t);
      ctrl222("", 10, $time());
   endfunction
endinterface

module toph222;
   if222 u_if222();
endmodule
