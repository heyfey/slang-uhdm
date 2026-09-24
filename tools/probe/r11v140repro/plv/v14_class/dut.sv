// § procLvBaseSelTrailAtIdx140
package p;
  typedef struct packed {
    logic       valid;
    logic [3:0] sat;
  } e_t;
endpackage
class k;
  p::e_t [1:0] tbl;
  p::e_t s;
  function void f(int r, int i);
    tbl[r].sat[i] = 1'b1;
    s.sat[i] = 1'b0;
  endfunction
endclass
module dut; endmodule
