// § patternCaseNoItems403
module top();
  typedef union tagged {
    struct { bit [3:0] val1, val2; } a;
    struct { bit [7:0] val1, val2; } b;
    void n;
  } u;
  u tmp;
  bit [3:0] val;
  int x;
  always @(val) unique casez (tmp) matches
    tagged n : x = 1;
    tagged b .* : x = 2;
  endcase
endmodule
