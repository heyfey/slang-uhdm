// r10svs2 ARM s1 — the WITNESS and its POSITIVE CONTROL side by side.
// `size` PARENS-LESS vs `size()` PARENS-FUL on a DYNAMIC array, inside a class
// method, in the same contexts SVSwitch/Packet.sv uses.
//
// The brief's law: parens-less -> ref_obj path element of the enclosing
// hier_path (hier_path span extends over the member name); parens-ful ->
// method_func_call.  Both cells are measured here so the positive control can
// never drift unobserved.
class pkt;
  byte data[];

  function byte pl();          // PARENS-LESS
    integer i;
    byte r;
    r = 0;
    for (i = 0; i < data.size; i++)   // the exact SVSwitch witness
      r = r ^ data[i];
    return r;
  endfunction

  function byte pf();          // PARENS-FUL — POSITIVE CONTROL
    integer i;
    byte r;
    r = 0;
    for (i = 0; i < data.size(); i++)
      r = r ^ data[i];
    return r;
  endfunction
endclass

module top;
  pkt p;
  initial begin
    p = new();
    $display("%0d %0d", p.pl(), p.pf());
  end
endmodule
