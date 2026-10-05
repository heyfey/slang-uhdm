// § lvHpIpsOperandChain244
package p;
  class inner; logic [63:0] data; endclass
  class item; logic [63:0] data; inner n; int w; endclass
  class ad;
    function int f(int a); return a; endfunction
    function void bus2reg(item rw, int n);
      for (int i = 0; i < 4; i++) begin
        rw.data[f(i)*8 +: 8] = 1;
        rw.data[$clog2(n)*8 -: 8] = 2;
        rw.n.data[i*8 +: 8] = 3;
        rw.data[i*8 +: 8] += 4;
        rw.data[rw.w*8 +: 8] = 5;
        rw.data[8*i +: (4*2)] = 6;
      end
    endfunction
  endclass
endpackage
module top; import p::*; ad w; initial w = new(); endmodule
