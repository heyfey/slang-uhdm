// § ovrMemberReadLocatesLeftover232
// a function leaving one member unwritten; overrides read a written and the unwritten member, by name and positionally
package p;
  typedef struct packed { int unsigned A; int unsigned B; int unsigned C; int unsigned D; logic E; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c;
    c.A = x;
    c.B = x + 1;
    c.C = 2;
    c.D = 7;
    return c;
  endfunction
endpackage
module leaf #(parameter int unsigned W = 1) (output logic [W-1:0] o);
  assign o = '0;
endmodule
module top(output logic [1:0] o1, output logic [2:0] o2, output logic [6:0] o3);
  localparam p::cfg_t CF = p::build(1);
  leaf #(.W(CF.C)) a (.o(o1));
  leaf #(.W(CF.B)) b (.o(o2));
  leaf #(CF.D) c (.o(o3));
endmodule
