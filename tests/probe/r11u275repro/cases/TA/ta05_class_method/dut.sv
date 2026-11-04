// § tfLocalArrRangeDimEnd275 — a ranged unpacked local in a class method
package p;
  class c;
    function int f(int s);
      bit [7:0] m [3:0];
      m[2] = s;
      return m[2];
    endfunction
  endclass
endpackage
module dut (output int o);
  initial begin
    p::c h = new;
    o = h.f(1);
  end
endmodule
