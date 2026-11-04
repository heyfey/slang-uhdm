// § patternCaseNoItems403
module top;
  typedef union tagged {
    struct { bit [3:0] val1, val2; } a;
    bit [7:0] b;
    void n;
  } u;
  u x;
  function int f();
    unique case (x) matches
      tagged b .v: return v;
      default: return 0;
    endcase
    return 1;
  endfunction
  int y;
  initial y = f();
endmodule
