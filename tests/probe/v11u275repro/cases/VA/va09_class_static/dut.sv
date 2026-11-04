// § tfLocalArrRangeDimEnd275 — a static class method with a ranged local
package p;
  class c;
    static function int f(int s);
      byte v [1:4];
      v[1] = s;
      return v[1];
    endfunction
  endclass
endpackage
module dut (output int o);
  initial o = p::c::f(3);
endmodule
