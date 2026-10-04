// § ovrMemberReadLocatesLeftover232
// the struct parameter is a module parameter one level down; the same member read twice; a macro-born override
`define RD(x) x.C
package p;
  typedef struct packed { int unsigned A; int unsigned C; logic E; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c;
    c.A = x;
    c.C = 3;
    return c;
  endfunction
endpackage
module leaf #(parameter int unsigned W = 1) (output logic [W-1:0] o);
  assign o = '0;
endmodule
module mid #(parameter p::cfg_t CF = p::build(4)) (output logic [2:0] o1, output logic [2:0] o2, output logic [2:0] o3);
  leaf #(.W(CF.C)) a (.o(o1));
  leaf #(.W(CF.C)) b (.o(o2));
  leaf #(.W(`RD(CF))) c (.o(o3));
endmodule
module top(output logic [2:0] o1, output logic [2:0] o2, output logic [2:0] o3);
  mid m (.o1(o1), .o2(o2), .o3(o3));
endmodule
