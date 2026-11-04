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
  initial case (tmp) matches
    tagged a '{.v, 0} : $display("a %d", v);
    tagged b '{.v1, .v2} : x = v1;
  endcase
endmodule
