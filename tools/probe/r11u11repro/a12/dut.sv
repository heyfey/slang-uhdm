// a12 — THE FORMAL x MEMBER MATRIX on an ASSEMBLED (function-built) base that
// carries a 1024-bit member.  Exercises `srlgAdjustSize` on the deferred slice
// exactly as r11u3's g2 exercised it on the immediate one.
package p;
  typedef enum logic [1:0] { E0 = 2'b00, E1 = 2'b01 } e2_t;
  typedef struct packed {
    int unsigned       W32;
    logic [3:0]        L4;
    logic [7:0]        L8;
    logic              L1;
    e2_t               EN;
    logic [15:0][63:0] WIDE;
  } cfg_t;
  function automatic cfg_t mk(input bit e);
    cfg_t c;
    c.WIDE = {16{64'h0}};
    c.W32 = 32;
    c.L4  = e == 1'b1 ? 4'b1010 : 4'b0;
    c.L8  = 8'b11001100;
    c.L1  = 1'b1;
    c.EN  = E1;
    return c;
  endfunction
endpackage

module top();
  parameter p::cfg_t C = p::mk(1'b1);
  fi   #(.P(C.L4)) i1();   // int          <- logic [3:0]
  fi   #(.P(C.L1)) i2();   // int          <- logic
  fi   #(.P(C.EN)) i3();   // int          <- enum logic [1:0]
  fl4  #(.P(C.L4)) i4();   // logic [3:0]  <- logic [3:0]
  fl2  #(.P(C.L4)) i5();   // logic [1:0]  <- logic [3:0]
  fu   #(.P(C.L4)) i6();   // untyped      <- logic [3:0]
  fb   #(.P(C.L1)) i7();   // bit          <- logic
  fl32 #(.P(C.L8)) i8();   // logic [31:0] <- logic [7:0]
  fiu  #(.P(C.W32)) i9();  // int unsigned <- int unsigned
endmodule

module fi   #(parameter int P = 0) ();          endmodule
module fiu  #(parameter int unsigned P = 0) (); endmodule
module fl4  #(parameter logic [3:0] P = 0) ();  endmodule
module fl2  #(parameter logic [1:0] P = 0) ();  endmodule
module fl32 #(parameter logic [31:0] P = 0) (); endmodule
module fu   #(parameter P = 0) ();              endmodule
module fb   #(parameter bit P = 0) ();          endmodule
