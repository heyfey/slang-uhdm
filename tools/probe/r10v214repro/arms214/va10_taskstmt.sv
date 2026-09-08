// v214 arm 10 — READ POSITIONS the grid's arm A does not spell: a for-loop
// bound, a case item, a concatenation operand, an array index, a system-call
// argument, and a nested user call, all inside a def clone body.
package pv10;
  parameter int ta10 = 4;
  parameter tb10 = ta10;
  parameter tc10 = ta10 + 1;
  function automatic int sink10(int a); return a; endfunction
  class C10;
    extern function int rd10(int sel);
  endclass
  function int C10::rd10(int sel);
    int r = 0;
    int arr[8];
    for (int i = 0; i < tb10; i++) r += i;
    case (sel)
      tb10: r += 1;
      tc10: r += 2;
      default: r += 3;
    endcase
    r += arr[tb10];
    r += $clog2(tb10);
    r += sink10(sink10(tb10));
    r += {tb10[1:0], tb10[1:0]};
    return r;
  endfunction
endpackage
module topv10;
  pv10::C10 c = new();
  int x;
  initial x = c.rd10(4);
endmodule
