// § ifacePortArrMemberChainPath401
typedef struct packed { logic valid; logic [3:0] num; } tag_t;
typedef struct packed { tag_t [2:0] regTag; } src_t;
interface WIF;
  src_t [1:0] writeSrcTag;
  modport S(output writeSrcTag);
endinterface
module sched(WIF.S w, input logic a);
  always_comb begin
    for (int i = 0; i < 2; i++) begin
      w.writeSrcTag[i].regTag[0].valid = a;
      w.writeSrcTag[i].regTag[1].num = 4'h1;
    end
  end
endmodule
module top(input logic a);
  WIF w();
  sched s(.w(w), .a(a));
endmodule
