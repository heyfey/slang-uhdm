// § ovrMemberReadLocatesLeftover232
// a for-generate instance reading the member, and a parenthesized override
package p;
  typedef struct packed { int unsigned A; int unsigned C; logic E; } cfg_t;
  function automatic cfg_t build();
    cfg_t c;
    c.A = 5;
    c.C = 2;
    return c;
  endfunction
endpackage
module leaf #(parameter int unsigned W = 1) (output logic [W-1:0] o);
  assign o = '0;
endmodule
module top(output logic [1:0] o1 [2], output logic [1:0] o2);
  localparam p::cfg_t CF = p::build();
  for (genvar i = 0; i < 2; i++) begin : g
    leaf #(.W(CF.C)) a (.o(o1[i]));
  end
  leaf #(.W((CF.C))) b (.o(o2));
endmodule
