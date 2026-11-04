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
  initial begin
    x = 1;
    priority case (tmp) matches
      tagged a .w &&& (val == 3) : x = 2;
    endcase
    x = 3;
  end
endmodule
