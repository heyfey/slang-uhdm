// r10uvm96 arm 1 — THE KEYWORD TABLE.  One cast per written casting-type
// keyword, all in ONE home (a module `initial`) and ONE carrier (a $display
// argument) so the ONLY thing that varies across the cells is the KEYWORD.
// The negative controls (`int` `byte` `bit` `logic` `reg`, the size cast and
// the two signing casts) sit beside the cells that must move, and every cell
// has a different span, so an arm that merely AGREED could not be mistaken for
// an arm that TESTED.
module g96_a1;
  int q;
  initial begin
    $display(real'(q));        // -> real_typespec
    $display(shortreal'(q));   // -> short_real_typespec
    $display(realtime'(q));    // -> time_typespec   (NOT real_typespec)
    $display(time'(q));        // -> time_typespec
    $display(int'(q));         // -> int_typespec        (control)
    $display(integer'(q));     // -> integer_typespec
    $display(longint'(q));     // -> long_int_typespec
    $display(shortint'(q));    // -> short_int_typespec
    $display(byte'(q));        // -> byte_typespec       (control)
    $display(bit'(q));         // -> bit_typespec        (control)
    $display(logic'(q));       // -> logic_typespec      (control)
    $display(reg'(q));         // -> logic_typespec      (control)
    $display(8'(q));           // -> integer_typespec INT:8 (control)
    $display(string'(q));      // -> string_typespec     (control)
    $display(signed'(q));      // -> $signed sys_func_call, NO cast op (control)
    $display(unsigned'(q));    // -> $unsigned sys_func_call, NO cast op (control)
  end
endmodule
