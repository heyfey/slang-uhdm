// r11v57 B6 — a PARAMETERIZED CLASS holding the buried call.  A class is a
// DesignComponent too; does the ParamEmit elaborated arm reach its localparams,
// and does the producer keep the call there?
package pk;
  typedef struct packed { logic [2:0] a; } req_t;                   // 3
  class cbox #(type CT = logic [1:0]);
    localparam int CW = (1 << $bits(CT));       // buried, class scope
    localparam int CC = (1 << $bits(req_t));    // CONTROL
  endclass
endpackage
module dut #(parameter type TP = logic [1:0]) (output logic o);
  localparam int M1 = (1 << $bits(TP));         // module twin of the same shape
  assign o = ^{M1[0]};
endmodule
