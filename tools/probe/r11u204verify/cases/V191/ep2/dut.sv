// § enumDefOwnerNotInstance191: a package enum imported explicitly by a module, by wildcard in a program, and used as a port type between parent and child
package p;
  typedef enum logic [2:0] {I0, I1, I2} e_t;
endpackage
module child import p::*; (input e_t ei, output e_t eo);
  assign eo = ei;
endmodule
module par;
  import p::e_t;
  e_t x, y;
  child c (.ei(x), .eo(y));
endmodule
program pg; import p::*; e_t z; endprogram
module top; par u (); pg q (); endmodule
