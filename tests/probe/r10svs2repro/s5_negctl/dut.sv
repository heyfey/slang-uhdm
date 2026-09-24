// r10svs2 ARM s5 — the NEGATIVE CONTROL.  A USER-DEFINED class method invoked
// with NO parens must NOT be swept into the law: it stays a call, not a path
// element.  If a candidate predicate moves any cell in this arm, the predicate
// is too wide and the arm says so.
//
// Note SVSwitch itself relies on this: Packet.sv:65/:77 call `cal_fcs`
// (a user function of the same class) with NO parens and NO receiver.
class sub;
  function void print(); $display("sub"); endfunction
  function int val();    return 7;        endfunction
endclass

class holder;
  sub o;
  int  n;

  function byte own();   // a user function of THIS class, no receiver, no parens
    return 3;
  endfunction

  function int f();
    int r;
    o.print;             // NEG CTL 1: user method, no parens, STATEMENT ctx
    r = o.val;           // NEG CTL 2: user method, no parens, EXPRESSION ctx
    r = r + own;         // NEG CTL 3: own user function, no receiver, no parens
                         //            (this is the SVSwitch `cal_fcs` shape)
    return r;
  endfunction
endclass

module top;
  holder h;
  initial begin
    h = new();
    h.o = new();
    $display("%0d", h.f());
  end
endmodule
