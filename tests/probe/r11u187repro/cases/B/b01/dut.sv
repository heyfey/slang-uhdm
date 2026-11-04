// § modAggTfArgCloneFollows180 (r11u183's paramAggTdLastWriter183, measured redundant by r11u187)
package p;
  typedef struct packed { logic [3:0] hi; logic [3:0] f; } op_t;
  function automatic logic [3:0] fa (op_t op); fa = op.f; endfunction
  parameter op_t OP = '{hi:'0, f: 4'h8};
endpackage
module top(output logic [3:0] o);
  import p::*;
  assign o = fa(OP);
endmodule
