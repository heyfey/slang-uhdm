package p223n;
   int    nv_one223;
endpackage

interface if223n();
   import p223n::*;
   logic sig223;
   modport mp223 (input sig223);
endinterface

module sub223n(if223n.mp223 p);
endmodule

module top223n;
   if223n u_n223();
   sub223n u_s223(u_n223.mp223);
endmodule
