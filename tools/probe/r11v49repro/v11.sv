// v11u49 arm v11 — is the discriminator the CLASS, or whether the body is EVALUATED?
package r;
  typedef struct packed { logic [7:0] CTL; logic [7:0] DAT; } rb_t;
  localparam rb_t RFCALL = '{CTL:8'd1, DAT:8'd2};  // pkg function, CALLED
  localparam rb_t RFDEAD = '{CTL:8'd3, DAT:8'd4};  // pkg function, NEVER called
  localparam rb_t RCUSED = '{CTL:8'd5, DAT:8'd6};  // class method, class USED
  localparam rb_t RCDEAD = '{CTL:8'd7, DAT:8'd8};  // class method, class never used
  function automatic int fcall(); return RFCALL.DAT; endfunction
  function automatic int fdead(); return RFDEAD.DAT; endfunction
  class CU; function int m(); return RCUSED.DAT; endfunction endclass
  class CD; function int m(); return RCDEAD.DAT; endfunction endclass
endpackage
module v11 import r::*; (output logic [31:0] o);
  CU cu = new();
  int q;
  initial q = cu.m();
  assign o = fcall() + q;
endmodule
