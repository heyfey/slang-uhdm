// r11u205 GS (copied from r11u195repro/evidence/residue/Q/q06): a port actual's trailing select in a generate-scope instance
package rp;
  typedef struct packed { logic [3:0] q; } en_t;
  typedef struct packed { en_t [3:0] class_en; logic x; } reg2hw_t;
endpackage
module sub(input rp::en_t class_en_i, output logic o);
  assign o = class_en_i.q[0];
endmodule
module top(input rp::reg2hw_t reg2hw_wrap, output logic [1:0] o);
  for (genvar k = 0; k < 2; k++) begin : gen_classes
    sub i_accu(.class_en_i(reg2hw_wrap.class_en[2]), .o(o[k]));
  end
endmodule
