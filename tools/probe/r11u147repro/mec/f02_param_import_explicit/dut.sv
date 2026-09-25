// § memberEnumCloneKeepsBase147
// case f02: the same with an explicit import of the enum type into package B
package ea2;
  typedef enum logic [1:0] {Lo = 2'd1, Hi = 2'd3} lv_e;
endpackage
package eb2;
  import ea2::lv_e;
  typedef struct packed { lv_e lvl; logic [1:0] pad; } c_t;
endpackage
module top(output logic [1:0] o);
  parameter eb2::c_t C = 4'b1100;
  assign o = '0;
endmodule
