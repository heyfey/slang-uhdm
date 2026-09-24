// v93 A9b — neighbouring families that must NOT move.
package p9;
  typedef logic [7:0] q9;
endpackage
module a9b_sysfn;
  typedef logic [11:0] t9;
  typedef struct packed { logic [3:0] a; logic [7:0] b; } s9;
  logic [63:0] v, r, r2;
  int          n;
  string       sname;
  logic [7:0]  arr [0:3];
  initial begin
    n = $bits(int);
    n = $bits(t9);
    n = $bits(s9);
    n = $bits(p9::q9);
    n = $bits(v);
    n = $size(arr);
    n = $size(arr, 1);
    n = $clog2(32);
    sname = $typename(t9);
    sname = $typename(v);
    r  = int'(v);
    r2 = t9'(v);
    r  = { << int { v } };
    case (n)
      $bits(int): r = 1;
      $bits(t9):  r = 2;
      default:    r = 3;
    endcase
  end
endmodule
