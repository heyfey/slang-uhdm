// § patternCaseNoItems403
class C;
  typedef union tagged { int i; void n; } u;
  u x;
  function int f();
    case (x) matches
      tagged i .k: return k;
      default: return 0;
    endcase
  endfunction
endclass
module top; C c = new; endmodule
