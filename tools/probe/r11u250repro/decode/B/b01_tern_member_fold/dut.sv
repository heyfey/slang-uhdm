// § patFlatTernPickedLeafSpan250 (decode of BlackBePipeInt #44904: a struct parameter whose members select another parameter's member through ?:)
package p;
  typedef struct packed { integer a; integer b; integer c; } s_t;
  localparam s_t dflt =
   '{a : 1
    ,b : 2
    ,c : 0
    };
  localparam s_t ovr =
   '{b : 5
    ,default : "inv"
    };
  localparam s_t cfg =
    '{
   a: (ovr.a == "inv")
        ? dflt.a
        : ovr.a
     ,
   b: (ovr.b == "inv")
        ? dflt.b
        : ovr.b
     ,
   c: (ovr.c == "inv") ? dflt.c : ovr.c
   };
endpackage
module top import p::*; (output integer o);
  assign o = cfg.a + cfg.b;
endmodule
