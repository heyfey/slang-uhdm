// § patternCaseNoItems403
module top;
  typedef union tagged {
    struct { bit [3:0] val1, val2; } a;
    bit [7:0] b;
    void n;
  } u;
  u x; int y;
  always_comb begin
    y = 0;
    priority casez (x) matches
      tagged n: y = 1;
      tagged b .w: y = w;
    endcase
  end
endmodule
