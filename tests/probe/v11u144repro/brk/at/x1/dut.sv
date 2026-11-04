// § methodSpanSkipsAttrs144
class C;
  (* a *) static function int f(); return 1; endfunction
  (* b *) task t(); endtask
  (* c *) (* d = 1 *) protected virtual task u(); endtask
endclass
module top; endmodule
