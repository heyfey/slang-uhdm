// r10vbuvm28 arm H — $bits THROUGH AN INSTANCE (hier path).  Golden's keep/fold
// decision for an interface member, with and without a base-less enum.
interface hif;
  typedef enum { H0, H1 } he_t;
  typedef struct packed { he_t c; bit [7:0] d; } hs_t;
  he_t      es;
  hs_t      ss;
  bit [7:0] vv;
  int       ii;
  he_t      ea [4];
endinterface

module hsub;
  typedef enum { S0, S1 } se_t;
  se_t sv;
  bit [7:0] sw;
endmodule

module gv28_h_hier;
  hif  u_if ();
  hsub u_sub ();
  int  r [12];
  initial begin
    r[0]  = $bits(u_if.es);      // base-less enum through an interface
    r[1]  = $bits(u_if.ss);      // struct containing one
    r[2]  = $bits(u_if.vv);      // plain vector  (control)
    r[3]  = $bits(u_if.ii);      // plain int     (control)
    r[4]  = $bits(u_if.ea);      // array of them
    r[5]  = $bits(u_if.ea[1]);   // element select through the instance
    r[6]  = $bits(u_sub.sv);     // module instance, base-less enum
    r[7]  = $bits(u_sub.sw);     // module instance, plain vector (control)
    // ($bits(hif::he_t) is rejected by slang: an interface is not a scope here)
  end
endmodule
