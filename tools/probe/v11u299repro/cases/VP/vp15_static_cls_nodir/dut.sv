// § inlineAggFormalTypeSpan299
class c;
  static function logic [3:0] f(struct packed { logic a; logic b; } [1:0] v); return v; endfunction
endclass
module dut(output logic [3:0] o);
  initial o = c::f(4'h9);
endmodule
