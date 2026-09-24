// r10uvm99 arm a10 — OTHER open-range-list contexts that must not move:
// covergroup bins, a `unique` set, a sequence, a case-inside with ranges next
// to an ordinary case, and an `inside` whose LHS is itself compound.
module omega99 (input logic clk99, input int cv99);
  int st99;
  covergroup cg99 @(posedge clk99);
    cp99: coverpoint cv99 {
      bins lo99  = {[0:3]};
      bins mid99 = {4, [5:7]};
      bins hi99  = {8, 9};
    }
  endgroup
  cg99 inst99 = new();
  always_comb begin
    case (cv99) inside
      [10:12]: st99 = 1;
      13, [14:15]: st99 = 2;
      default: st99 = 0;
    endcase
  end
  always_comb begin
    case (cv99)
      16: st99 = 3;
      default: st99 = 4;
    endcase
  end
  function automatic bit w1(int av, int bv);
    return (av + bv) inside {[1:4]};
  endfunction
  function automatic bit w2(int av);
    return !(av inside {[2:6]});
  endfunction
endmodule
