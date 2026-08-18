// r10uvm95 grid E — element TYPES: what width does Surelog's Bits() give?
package pF95;
  typedef struct { bit [11:0] hi; byte lo; } us95_t;       // UNPACKED struct
  typedef union packed { bit [7:0] a; bit [7:0] b; } up95_t;
  typedef enum bit [2:0] { Z0, Z1 } en95_t;
endpackage
module mE95(output int o);
  import pF95::*;
  real       r1;   shortreal sr1;  realtime rt1;  time t1;
  integer    ig1;  chandle   ch1;  us95_t    su1;  up95_t pu1;  en95_t e1;
  real       ra [3];
  us95_t     sua[2];
  logic      l1;   reg r2;   bit b3;
  int        r;
  initial begin
    r = $bits(r1);
    r = $bits(sr1);
    r = $bits(rt1);
    r = $bits(t1);
    r = $bits(ig1);
    r = 0; // chandle: slang rejects
    r = $bits(su1);
    r = $bits(pu1);
    r = $bits(e1);
    r = 0; // real array: slang rejects
    r = $bits(ra[1]);
    r = $bits(sua);
    r = $bits(sua[1]);
    r = $bits(l1);
    r = $bits(r2);
    r = $bits(b3);
    o = r;
  end
endmodule
